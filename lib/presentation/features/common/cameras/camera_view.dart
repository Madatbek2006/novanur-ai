import 'package:baiqavisit/core/extensions/list_extensions.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class CameraView extends StatefulWidget {
  final CameraController? controller;
  final void Function(CameraController controller) onControllerReady;
  final Widget? child;

  const CameraView({
    super.key,
    required this.onControllerReady,
    this.child, required this.controller,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView>
    with WidgetsBindingObserver {
  CameraController? controller;
  List<CameraDescription>? cameras;

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
    List<CameraDescription> cameras = await availableCameras();
    Logger().w("initCamera camera count = ${cameras.length}");
    var backCameras =
    cameras.filterIf((c) => c.lensDirection == CameraLensDirection.back);
    Logger().w("initCamera back camera count = ${backCameras.length}");
    if (backCameras.isNotEmpty) {
      final CameraController newController = CameraController(
        backCameras[backCameras.length-1],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await newController.initialize();

      setState(() {
        controller?.dispose();
        controller = newController;
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

    return CameraPreview(
        cam,
      child: widget.child,
    );
  }
}
