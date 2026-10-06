import 'dart:typed_data';

import 'package:nurnova_ai/utils/web/browser_vision_models.dart';

/// Non-web builds never show the web dashboard; this only satisfies the compiler.
class BrowserVision {
  BrowserVision._();

  static Never _unsupported() => throw UnsupportedError('BrowserVision is web-only');

  static Future<({BrowserCameraStatus status, int cameras})> cameraStatus() async =>
      (status: BrowserCameraStatus.unsupported, cameras: 0);

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

  static Future<BrowserImage> normalizeImage(
    Uint8List bytes, {
    required String name,
    int maxSide = 2048,
    double quality = 0.9,
  }) =>
      _unsupported();

  static Future<PickedFileData?> pickImage() async => null;

  static void setDropHandler(
    void Function(PickedFileData? file) onFile,
    void Function(bool dragging) onDragChange,
  ) {}

  static void clearDropHandler() {}

  static Future<String> recognizeText(
    Uint8List bytes,
    String languages,
    void Function(String status, double progress) onProgress,
  ) =>
      _unsupported();

  static Future<VisionBarcode?> decodeBarcodeFromImage(Uint8List bytes) => _unsupported();

  static Future<VisionBarcode?> decodeBarcodeFromVideo(Object video) async => null;

  static Future<VisionObjects> detectObjectsInImage(Uint8List bytes) => _unsupported();

  static Future<VisionObjects?> detectObjectsInVideo(Object video) async => null;

  static void preload(String feature) {}
}
