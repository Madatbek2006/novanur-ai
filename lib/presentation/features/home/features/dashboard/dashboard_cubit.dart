import 'dart:async';

import 'package:baiqavisit/core/enum/enums.dart';
import 'package:baiqavisit/core/extensions/list_extensions.dart';
import 'package:baiqavisit/domain/models/dashboard/dashboard_button_data.dart';
import 'package:baiqavisit/presentation/support/cubit/base_cubit.dart';
import 'package:camera/camera.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

part 'dashboard_cubit.freezed.dart';
part 'dashboard_state.dart';

@injectable
class DashboardCubit extends BaseCubit<DashboardState, DashboardEvent> {



  DashboardCubit(
  ) : super(const DashboardState());

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

  // void sendTakenAttendancePhoto() {
  //   updateState((state)=>state.copyWith(
  //     isSendingRequest: true
  //   ));
  //   logger.d("TTT=> ${states.takenPhotoFile==null}////${states.takenPhotoFile}");
  //   _photoAnalysisRepository.fetchPhotoAnalysis(states.takenPhotoFile!,
  //       aiImageDescriptionPrompt
  //   )
  //   .initFuture()
  //   .onStart((){})
  //   .onSuccess((data){
  //     updateState((state)=>state.copyWith(
  //         isSendingRequest: false
  //     ));
  //     logger.d("TTT=>${data}");
  //     updateState((state) => state.copyWith(title: data??""));
  //     emitEvent(DashboardEvent(DashboardEventType.openResultScreen));
  //
  //   })
  //   .onError((error){
  //     logger.d("TTT=> $error");
  //   })
  //   .onFinished((){})
  //   .executeFuture();
  // }


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

      case DashboardButtonType.findObject:

    }
  }


}





