import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';
import 'package:nurnova_ai/utils/desktop/desktop_objects.dart';
import 'package:nurnova_ai/utils/desktop/desktop_ocr.dart';
import 'package:nurnova_ai/utils/web/browser_vision_models.dart';

/// То, что сайт делает в браузере, — в десктопной версии (Windows), нативно:
/// Tesseract вместо tesseract.js, zxing-cpp вместо ZXing на JS, YOLO через
/// onnxruntime вместо MediaPipe. API тот же, поэтому кубит и экраны сайта
/// работают без изменений.
///
/// Камера на компьютере своя — `DesktopCameraView`: методы, которым нужен
/// элемент `<video>`, есть только у браузера. Телефон этот класс не трогает
/// вовсе: у него свой интерфейс с ML Kit.
class BrowserVision {
  BrowserVision._();

  static final _objects = DesktopObjects();
  static final _ocr = DesktopOcr();

  static void Function(PickedFileData? file)? _onDrop;
  static void Function(bool dragging)? _onDragChange;

  static Future<({BrowserCameraStatus status, int cameras})> cameraStatus() async {
    try {
      final cameras = await availableCameras();
      return (
        status: cameras.isEmpty ? BrowserCameraStatus.none : BrowserCameraStatus.granted,
        cameras: cameras.length,
      );
    } catch (_) {
      // У камеры нет реализации под эту систему (так на маке, где мы только
      // проверяем десктопный код).
      return (status: BrowserCameraStatus.unsupported, cameras: 0);
    }
  }

  static void prepareVideo(Object video) {}

  static Future<CameraStartResult> startCamera(Object video, {bool front = false}) async =>
      const CameraStartResult(error: BrowserCameraStatus.unsupported);

  static void stopCamera(Object video) {}

  static Future<BrowserImage?> captureFrame(
    Object video, {
    int maxSide = 2048,
    double quality = 0.9,
  }) async =>
      null;

  /// Как у сайта: прямо стоящий JPEG не больше [maxSide] по длинной стороне.
  static Future<BrowserImage> normalizeImage(
    Uint8List bytes, {
    required String name,
    int maxSide = 2048,
    double quality = 0.9,
  }) =>
      Isolate.run(() => normalizeImageSync(bytes, name: name, maxSide: maxSide, quality: quality));

  static Future<PickedFileData?> pickImage() async {
    final file = await openFile(acceptedTypeGroups: const [
      XTypeGroup(
        label: 'images',
        extensions: ['jpg', 'jpeg', 'png', 'webp', 'bmp', 'gif'],
        uniformTypeIdentifiers: ['public.image'],
      ),
    ]);
    if (file == null) return null;
    return PickedFileData(
      name: file.name,
      type: imageMimeType(file.name),
      bytes: await file.readAsBytes(),
    );
  }

  /// Перетаскивание и вставку на компьютере ловит `DesktopDropZone` и
  /// передаёт сюда — тем же обработчикам, что ставит экран сайта.
  static void setDropHandler(
    void Function(PickedFileData? file) onFile,
    void Function(bool dragging) onDragChange,
  ) {
    _onDrop = onFile;
    _onDragChange = onDragChange;
  }

  static void clearDropHandler() {
    _onDrop = null;
    _onDragChange = null;
  }

  static void handleDrop(PickedFileData? file) => _onDrop?.call(file);

  static void handleDragChange(bool dragging) => _onDragChange?.call(dragging);

  static Future<String> recognizeText(
    Uint8List bytes,
    String languages,
    void Function(String status, double progress) onProgress,
  ) =>
      _ocr.recognize(bytes, languages, onProgress);

  static Future<VisionBarcode?> decodeBarcodeFromImage(Uint8List bytes) =>
      Isolate.run(() async {
        final code = await zx.readBarcodeImagePath(
          XFile.fromData(bytes),
          DecodeParams(tryHarder: true, tryInverted: true, maxSize: 1600),
        );
        final text = code.text;
        if (!code.isValid || text == null || text.isEmpty) return null;
        return VisionBarcode(text: text, format: zx.barcodeFormatName(code.format ?? 0));
      });

  static Future<VisionBarcode?> decodeBarcodeFromVideo(Object video) async => null;

  static Future<VisionObjects> detectObjectsInImage(Uint8List bytes) => _objects.detect(bytes);

  static Future<VisionObjects?> detectObjectsInVideo(Object video) async => null;

  /// Как у сайта: начать загружать то, что понадобится режиму, заранее.
  static void preload(String feature) {
    try {
      if (feature == 'objects') _objects.preload();
      if (feature.startsWith('text:')) _ocr.preload();
    } catch (e) {
      Logger().w('BrowserVision: $feature не загрузился заранее: $e');
    }
  }
}

/// Прямо стоящий JPEG не больше [maxSide] — то, что сайт делает на canvas.
BrowserImage normalizeImageSync(
  Uint8List bytes, {
  required String name,
  int maxSide = 2048,
  double quality = 0.9,
}) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const FormatException('не картинка');
  var image = img.bakeOrientation(decoded);
  final longest = math.max(image.width, image.height);
  if (longest > maxSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: maxSide, interpolation: img.Interpolation.average)
        : img.copyResize(image, height: maxSide, interpolation: img.Interpolation.average);
  }
  // У JPEG нет прозрачности: прозрачное — на белый, как у сайта.
  if (image.hasAlpha) {
    image = img.compositeImage(
      img.Image(width: image.width, height: image.height, backgroundColor: img.ColorRgb8(255, 255, 255)),
      image,
    );
  }
  return BrowserImage(
    bytes: img.encodeJpg(image, quality: (quality * 100).round()),
    width: image.width,
    height: image.height,
    name: name,
  );
}
