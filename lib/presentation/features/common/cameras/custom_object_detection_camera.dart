import 'dart:async';
import 'dart:ui' as ui;

import 'package:baiqavisit/presentation/features/common/cameras/custom_object_detection_painter.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'custom_object_detector.dart';
import 'dart:typed_data';
import 'dart:math';
import 'package:logger/logger.dart';

class CustomObjectDetectionCamera extends StatefulWidget {
  const CustomObjectDetectionCamera({super.key});

  @override
  State<CustomObjectDetectionCamera> createState() =>
      _CustomObjectDetectionCameraState();
}

class _CustomObjectDetectionCameraState
    extends State<CustomObjectDetectionCamera> {
  final _logger = Logger();
  CameraController? _controller;
  final CustomObjectDetector _detector = CustomObjectDetector(inputSize: 300);
  List<DetectedObjectResult> _objects = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _logger.d('DDD: Initializing camera and detector');
    await _detector.loadModel();

    final cameras = await availableCameras();
    final camera = cameras.first;
    _logger.d('DDD: Available cameras: ${cameras.length}');

    _controller =
        CameraController(camera, ResolutionPreset.medium, enableAudio: false);
    await _controller!.initialize();
    _logger.d('DDD: Camera controller initialized');

    _controller!.startImageStream(_processCameraImage);
    _logger.d('DDD: Started image stream');

    if (mounted) setState(() {});
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_busy) return;
    _busy = true;
    try {
      _logger.d('DDD: Processing camera image');
      _logger.d('DDD: Image converted to RGB');
      final rgbBytes = _convertYUV420ToRGB(image);
      _logger.d('DDD: rgbBytes RGB length = ${rgbBytes.length}, expected = ${_detector.inputSize * _detector.inputSize * 3}');
      final resizedRgb = await resizeRgb(rgbBytes, image.width, image.height, _detector.inputSize);

      _logger.d('DDD: resizedRgb  length = ${resizedRgb.length}, expected = ${_detector.inputSize * _detector.inputSize * 3}');
      final results = await _detector.predict(resizedRgb);
      _objects = results;
      _logger.d('DDD: Detected ${_objects.length} objects');

      if (mounted) setState(() {});
      _busy = false;

    } catch (e, st) {
      _logger.e('DDD: Error processing image ${e.toString()} ${st.toString()}');
    } finally {

    }
  }

  Uint8List _convertYUV420ToRGB(CameraImage image) {
    final width = image.width;
    final height = image.height;

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final rgb = Uint8List(width * height * 3);
    int index = 0;

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        final yp = yPlane.bytes[i * yPlane.bytesPerRow + j];

        final uIndex = (i ~/ 2) * uPlane.bytesPerRow + (j ~/ 2) * (uPlane.bytesPerPixel ?? 1);
        final vIndex = (i ~/ 2) * vPlane.bytesPerRow + (j ~/ 2) * (vPlane.bytesPerPixel ?? 1);

        final up = uPlane.bytes[uIndex];
        final vp = vPlane.bytes[vIndex];

        final r = (yp + 1.402 * (vp - 128)).clamp(0, 255).toInt();
        final g = (yp - 0.344136 * (up - 128) - 0.714136 * (vp - 128)).clamp(0, 255).toInt();
        final b = (yp + 1.772 * (up - 128)).clamp(0, 255).toInt();

        rgb[index++] = r;
        rgb[index++] = g;
        rgb[index++] = b;
      }
    }

    return rgb;
  }




  @override
  void dispose() {
    _logger.d('DDD: Disposing camera controller');
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      _logger.d('DDD: Controller not initialized, showing loading indicator');
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(_controller!),
        Positioned.fill(
          child: CustomPaint(
            painter: ObjectDetectionPainter(
              objects: _objects,
              previewSize: Size(
                _controller!.value.previewSize!.height,
                _controller!.value.previewSize!.width,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


Future<Uint8List> resizeRgb(Uint8List rgb, int originalWidth, int originalHeight, int targetSize) async {
  final completer = Completer<ui.Image>();

  // Преобразуем RGB -> RGBA (добавляем альфу = 255)
  final rgba = Uint8List(originalWidth * originalHeight * 4);
  for (int i = 0, j = 0; i < rgb.length; i += 3, j += 4) {
    rgba[j] = rgb[i];       // R
    rgba[j + 1] = rgb[i + 1]; // G
    rgba[j + 2] = rgb[i + 2]; // B
    rgba[j + 3] = 255;      // A
  }

  ui.decodeImageFromPixels(
    rgba,
    originalWidth,
    originalHeight,
    ui.PixelFormat.rgba8888,
        (img) => completer.complete(img),
  );

  final image = await completer.future;

  // Масштабируем
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final paint = ui.Paint();
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, originalWidth.toDouble(), originalHeight.toDouble()),
    Rect.fromLTWH(0, 0, targetSize.toDouble(), targetSize.toDouble()),
    paint,
  );

  final picture = recorder.endRecording();
  final imgResized = await picture.toImage(targetSize, targetSize);
  final byteData = await imgResized.toByteData(format: ui.ImageByteFormat.rawRgba);

  // Преобразуем обратно в RGB (отбрасываем альфу)
  final resizedRgb = Uint8List(targetSize * targetSize * 3);
  final bytes = byteData!.buffer.asUint8List();
  for (int i = 0, j = 0; i < bytes.length; i += 4, j += 3) {
    resizedRgb[j] = bytes[i];     // R
    resizedRgb[j + 1] = bytes[i + 1]; // G
    resizedRgb[j + 2] = bytes[i + 2]; // B
  }

  return resizedRgb;
}
