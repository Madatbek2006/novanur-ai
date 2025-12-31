import 'dart:ui';
import 'package:baiqavisit/core/extensions/list_extensions.dart';
import 'package:baiqavisit/presentation/application/manager/object_detection_manager.dart';
import 'package:baiqavisit/presentation/features/common/cameras/object_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:logger/logger.dart';

class ObjectDetectionCamera extends StatefulWidget {
  const ObjectDetectionCamera({super.key, this.child, required this.onControllerReady});
  final void Function(CameraController controller) onControllerReady;
  final Widget? child;

  @override
  State<ObjectDetectionCamera> createState() => _ObjectDetectionCameraState();
}

class _ObjectDetectionCameraState extends State<ObjectDetectionCamera> {
  CameraController? _controller;
  List<DetectedObject> _objects = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await ObjectDetectionManager().init();
    List<CameraDescription> cameras = await availableCameras();
    Logger().w("initCamera camera count = ${cameras.length}");
    var backCameras =
    cameras.filterIf((c) => c.lensDirection == CameraLensDirection.back);
    Logger().w("initCamera back camera count = ${backCameras.length}");
    if (backCameras.isNotEmpty) {
      _controller = CameraController(
        backCameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();

      _controller!.startImageStream(_processCameraImage);
      widget.onControllerReady(_controller!);

    } else {
      if (mounted) setState(() {});
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_busy) return;
    _busy = true;

    final inputImage = _toInputImage(image, _controller!.description.sensorOrientation);
    Logger().d('DDD=>before process');
    final detected = await ObjectDetectionManager().detect(inputImage);
    _objects = detected.where((element) => element.labels.isNotEmpty).toList();

    Logger().d('DDD=>detected ${detected.length} objects');

    if (mounted) setState(() {});
    _busy = false;
  }

  InputImage _toInputImage(CameraImage image, int rotation) {
    final bytes = _convertYUV420ToNV21(image);

    final imageRotation =
        InputImageRotationValue.fromRawValue(rotation) ??
            InputImageRotation.rotation0deg;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: imageRotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.width,
      ),
    );
  }




  @override
  void dispose() {
    _controller?.dispose();
    ObjectDetectionManager().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Stack(
        children: [
          const Center(child: CircularProgressIndicator()),
          if(widget.child!=null)
          widget.child!
        ],
      );
    }

    return Stack(
      children: [
        CameraPreview(_controller!,),
        Positioned.fill(
          child: CustomPaint(
            painter: ObjectPainter(
              objects: _objects,
              previewSize: _controller!.value.previewSize!,
            ),
          ),
        ),
        if(widget.child!=null)
        widget.child!
      ],
    );
  }

  Uint8List _convertYUV420ToNV21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final int ySize = width * height;
    final int uvSize = width * height ~/ 2;

    final Uint8List nv21 = Uint8List(ySize + uvSize);

    // copy Y
    int offset = 0;
    for (final Plane plane in image.planes) {
      if (plane.bytesPerRow == width) {
        nv21.setRange(offset, offset + plane.bytes.length, plane.bytes);
        offset += plane.bytes.length;
      } else {
        for (int i = 0; i < height; i++) {
          final start = i * plane.bytesPerRow;
          nv21.setRange(offset, offset + width, plane.bytes.sublist(start, start + width));
          offset += width;
        }
      }
      break;
    }

    // copy VU
    final Plane uPlane = image.planes[1];
    final Plane vPlane = image.planes[2];

    int uvRowStride = uPlane.bytesPerRow;
    int uvPixelStride = uPlane.bytesPerPixel!;

    int uvOffset = ySize;

    for (int row = 0; row < height ~/ 2; row++) {
      for (int col = 0; col < width ~/ 2; col++) {
        int uIndex = row * uvRowStride + col * uvPixelStride;
        int vIndex = row * vPlane.bytesPerRow + col * vPlane.bytesPerPixel!;

        nv21[uvOffset++] = vPlane.bytes[vIndex];
        nv21[uvOffset++] = uPlane.bytes[uIndex];
      }
    }

    return nv21;
  }

}
