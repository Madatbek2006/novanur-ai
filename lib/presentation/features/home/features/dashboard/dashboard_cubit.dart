import 'dart:async';

import 'package:baiqavisit/core/enum/enums.dart';
import 'package:baiqavisit/core/extensions/list_extensions.dart';
import 'package:baiqavisit/core/handler/future_handler.dart';
import 'package:baiqavisit/data/repositories/photo_analysis_repository.dart';
import 'package:baiqavisit/domain/models/dashboard/dashboard_button_data.dart';
import 'package:baiqavisit/presentation/support/cubit/base_cubit.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'dashboard_cubit.freezed.dart';
part 'dashboard_state.dart';

@injectable
class DashboardCubit extends BaseCubit<DashboardState, DashboardEvent> {
  WebSocketChannel? channel;
  bool _isSendingRequest = false;
  final FlutterTts flutterTts = FlutterTts();


  final PhotoAnalysisRepository _photoAnalysisRepository;


  DashboardCubit(this._photoAnalysisRepository) : super(const DashboardState());

  @override
  Future<void> close() async {
    await _closeCamera();

    super.close();
  }

  void setInitialData() {
    setupCamera();
  }

  void setupCamera() async {
    if (await checkAndRequestCameraPermission()) {
      await _initCamera().then((value) {
        updateState((state) => state.copyWith(
              cameraInitState: LoadingState.success,
            ));


      });
    } else {
      updateState((state) => state.copyWith(
            cameraInitState: LoadingState.error,
          ));
    }
  }

  Future<bool> checkAndRequestCameraPermission() async {
    var status = await Permission.camera.status;
    logger.w("checkAndRequestCameraPermission status: $status");
    if (status.isGranted) {
      return true;
    } else if (status.isDenied || status.isLimited) {
      status = await Permission.camera.request();
      return status.isGranted;
    }
    return false;
  }

  Future<void> _initCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    logger.w("initCamera camera count = ${cameras.length}");
    var backCameras =
        cameras.filterIf((c) => c.lensDirection == CameraLensDirection.back);
    logger.w("initCamera back camera count = ${backCameras.length}");
    if (backCameras.isNotEmpty) {
      final CameraController cameraController = CameraController(
        backCameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await cameraController.initialize();
      updateState((state) => state.copyWith(
            // cameras: cameras,
            cameraController: cameraController,
            cameraInitState: LoadingState.loading,
          ));
    } else {
      updateState((state) => state.copyWith(
            // cameras: cameras,
            cameraController: null,
            cameraInitState: LoadingState.error,
          ));
    }
  }

  Future<void> _closeCamera() async {
    await states.cameraController?.dispose();
  }



  void showPicture(bool isVisible) {
    emitEvent(DashboardEvent(DashboardEventType.onShowTakenPhoto));
  }

  void setTakenPhoto(XFile photo) {
    updateState((state) => state.copyWith(
          takenPhotoFile: photo,
        ));
  }

  void setDashboardButtonType(DashboardButtonType type) {
    updateState((state) => state.copyWith(
      type: type,
    ));

    switch(type){

      case DashboardButtonType.scanText:

      case DashboardButtonType.scanBarcode:

      case DashboardButtonType.describeScene:

      case DashboardButtonType.objectRecognition:

      // case DashboardButtonType.findObject:

    }
  }

  void getProductData(String? barcode) {
    if(_isSendingRequest || barcode==null) return;
    _isSendingRequest=true;
    _photoAnalysisRepository.getProductData(barcode)
        .initFuture()
        .onStart(() {})
        .onSuccess((data) {
      flutterTts.speak(data);
      Future.delayed(Duration(seconds: 5),(){
        _isSendingRequest=false;
      });
    })
        .onError((error) {
      _isSendingRequest=false;
    })
        .onFinished(() {})
        .executeFuture();
  }


}





