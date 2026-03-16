import 'dart:typed_data';

import 'package:baiqavisit/core/extensions/list_extensions.dart';
import 'package:baiqavisit/presentation/application/manager/object_detection_manager.dart';
import 'package:baiqavisit/presentation/features/common/cameras/object_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:logger/logger.dart';

class CameraView extends StatefulWidget {
  final CameraController? controller;

  final bool isObjRec;
  final void Function(CameraController controller) onControllerReady;
  final Widget? child;

  const CameraView({
    super.key,
    required this.onControllerReady,
    this.child, required this.controller,
    this.isObjRec=false,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView>
    with WidgetsBindingObserver {
  CameraController? controller;
  List<CameraDescription>? cameras;
  List<DetectedObject> _objects = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cam = controller;

    if (cam == null || !cam.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      cam.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initCamera().then((value) {
        widget.onControllerReady(controller!);
      });
    }
  }
  Future<void> initCamera() async {
    await ObjectDetectionManager().init();
    List<CameraDescription> cameras = await availableCameras();
    Logger().w("initCamera camera count = ${cameras.length}");
    var backCameras =
    cameras.filterIf((c) => c.lensDirection == CameraLensDirection.back);
    Logger().w("initCamera back camera count = ${backCameras.length}");
    if (backCameras.isNotEmpty) {
      final CameraController newController = CameraController(
        backCameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await newController.initialize();

      setState(() {
        controller?.stopImageStream();
        controller?.dispose();
        controller = newController;
        newController.startImageStream(_processCameraImage);

        widget.onControllerReady(newController);
      });
    } else {

    }
  }

  // Future<void> initCamera() async {
  //   try {
  //     cameras ??= await availableCameras();
  //
  //     final firstCamera = cameras!.first;
  //
  //     final newController = CameraController(
  //       firstCamera,
  //       ResolutionPreset.high,
  //       enableAudio: false,
  //     );
  //
  //     await newController.initialize();
  //
  //     setState(() {
  //       controller?.dispose();
  //       controller = newController;
  //     });
  //
  //     widget.onControllerReady(newController);
  //   } catch (_) {}
  // }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cam = controller;

    if (cam == null || !cam.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        CameraPreview(cam,),
        if(widget.isObjRec)
        Positioned.fill(
          child: CustomPaint(
            painter: ObjectPainter(
              objects: _objects,
              previewSize: cam.value.previewSize!,
            ),
          ),
        ),
      ],
    );

  }


  Future<void> _processCameraImage(CameraImage image) async {
    if (_busy||!widget.isObjRec) return;
    _busy = true;

    final inputImage = _toInputImage(image, controller!.description.sensorOrientation);
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
