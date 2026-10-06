import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'dart:ui';

import 'package:nurnova_ai/utils/web/browser_vision_models.dart';

// The project's build_runner ships an analyzer that predates extension types,
// so this binding sticks to dynamic calls from dart:js_interop_unsafe.

/// Dart side of web/vision/nurnova_vision.js.
class BrowserVision {
  BrowserVision._();

  static JSObject? get _visionOrNull => globalContext.getProperty<JSObject?>('nurnovaVision'.toJS);

  static JSObject get _vision {
    final vision = _visionOrNull;
    if (vision == null) {
      throw StateError('vision/nurnova_vision.js is not loaded (check web/index.html)');
    }
    return vision;
  }

  static Future<R> _call<R extends JSAny?>(String method, [List<JSAny?> args = const []]) =>
      _vision.callMethodVarArgs<JSPromise<R>>(method.toJS, args).toDart;

  static Future<({BrowserCameraStatus status, int cameras})> cameraStatus() async {
    final json = _decode((await _call<JSString>('cameraStatus')).toDart);
    return (
      status: BrowserCameraStatus.parse(json['status'] as String?),
      cameras: (json['cameras'] as num?)?.toInt() ?? 0,
    );
  }

  /// Styles a freshly created <video> element for previews.
  static void prepareVideo(Object video) =>
      _vision.callMethod<JSAny?>('prepareVideo'.toJS, video as JSObject);

  static Future<CameraStartResult> startCamera(Object video, {bool front = false}) async {
    final json = _decode(
      (await _call<JSString>('startCamera', [video as JSObject, (front ? 'user' : 'environment').toJS])).toDart,
    );
    if (json['ok'] != true) {
      return CameraStartResult(error: BrowserCameraStatus.parse(json['error'] as String?));
    }
    return CameraStartResult(
      videoSize: Size((json['width'] as num).toDouble(), (json['height'] as num).toDouble()),
      cameras: (json['cameras'] as num?)?.toInt() ?? 1,
    );
  }

  static void stopCamera(Object video) =>
      _vision.callMethod<JSAny?>('stopCamera'.toJS, video as JSObject);

  static Future<BrowserImage?> captureFrame(
    Object video, {
    int maxSide = 2048,
    double quality = 0.9,
  }) async {
    final frame = await _call<JSObject?>('captureFrame', [video as JSObject, maxSide.toJS, quality.toJS]);
    return frame == null ? null : _image(frame, 'camera.jpg');
  }

  /// Decodes any image the browser understands into an upright JPEG.
  /// Throws if the browser can't decode it (e.g. HEIC outside Safari).
  static Future<BrowserImage> normalizeImage(
    Uint8List bytes, {
    required String name,
    int maxSide = 2048,
    double quality = 0.9,
  }) async {
    final image = await _call<JSObject>('normalizeImage', [bytes.toJS, maxSide.toJS, quality.toJS]);
    // The bytes are JPEG now, whatever the file was.
    return _image(image, '${name.replaceFirst(RegExp(r'\.[^./]*$'), '')}.jpg');
  }

  static Future<PickedFileData?> pickImage() async {
    final file = await _call<JSObject?>('pickImage');
    return file == null ? null : _pickedFile(file);
  }

  static void setDropHandler(
    void Function(PickedFileData? file) onFile,
    void Function(bool dragging) onDragChange,
  ) {
    _vision.callMethod<JSAny?>(
      'setDropHandler'.toJS,
      ((JSObject? file) => onFile(file == null ? null : _pickedFile(file))).toJS,
      ((JSBoolean dragging) => onDragChange(dragging.toDart)).toJS,
    );
  }

  static void clearDropHandler() => _visionOrNull?.callMethod<JSAny?>('clearDropHandler'.toJS);

  static Future<String> recognizeText(
    Uint8List bytes,
    String languages,
    void Function(String status, double progress) onProgress,
  ) async {
    final text = await _call<JSString>('recognizeText', [
      bytes.toJS,
      languages.toJS,
      ((JSString status, JSNumber progress) => onProgress(status.toDart, progress.toDartDouble)).toJS,
    ]);
    return text.toDart;
  }

  static Future<VisionBarcode?> decodeBarcodeFromImage(Uint8List bytes) async =>
      _barcode(await _call<JSString?>('decodeBarcodeFromImage', [bytes.toJS]));

  static Future<VisionBarcode?> decodeBarcodeFromVideo(Object video) async =>
      _barcode(await _call<JSString?>('decodeBarcodeFromVideo', [video as JSObject]));

  static Future<VisionObjects> detectObjectsInImage(Uint8List bytes) async =>
      _objects((await _call<JSString>('detectObjectsInImage', [bytes.toJS])).toDart);

  static Future<VisionObjects?> detectObjectsInVideo(Object video) async {
    final json = await _call<JSString?>('detectObjectsInVideo', [video as JSObject]);
    return json == null ? null : _objects(json.toDart);
  }

  /// `text:<langs>`, `barcode` or `objects`.
  static void preload(String feature) {
    if (feature.isEmpty) return;
    _visionOrNull?.callMethod<JSAny?>('preload'.toJS, feature.toJS);
  }

  static Map<String, dynamic> _decode(String json) => jsonDecode(json) as Map<String, dynamic>;

  static BrowserImage _image(JSObject image, String name) => BrowserImage(
        bytes: image.getProperty<JSUint8Array>('bytes'.toJS).toDart,
        width: image.getProperty<JSNumber>('width'.toJS).toDartInt,
        height: image.getProperty<JSNumber>('height'.toJS).toDartInt,
        name: name,
      );

  static PickedFileData _pickedFile(JSObject file) => PickedFileData(
        name: file.getProperty<JSString>('name'.toJS).toDart,
        type: file.getProperty<JSString>('type'.toJS).toDart,
        bytes: file.getProperty<JSUint8Array>('bytes'.toJS).toDart,
      );

  static VisionBarcode? _barcode(JSString? json) {
    if (json == null) return null;
    final map = _decode(json.toDart);
    return VisionBarcode(text: map['text'] as String? ?? '', format: map['format'] as String? ?? '');
  }

  static VisionObjects _objects(String json) {
    final map = _decode(json);
    final objects = (map['objects'] as List).cast<Map<String, dynamic>>().map((o) {
      double n(String key) => (o[key] as num?)?.toDouble() ?? 0;
      return VisionObject(
        label: o['label'] as String? ?? '',
        score: n('score'),
        box: Rect.fromLTWH(n('x'), n('y'), n('w'), n('h')),
      );
    }).toList();
    return VisionObjects(
      imageSize: Size((map['width'] as num).toDouble(), (map['height'] as num).toDouble()),
      objects: objects,
    );
  }
}
