import 'dart:async';

import 'package:baiqavisit/core/enum/enums.dart';
import 'package:baiqavisit/core/extensions/list_extensions.dart';
import 'package:baiqavisit/core/handler/future_handler.dart';
import 'package:baiqavisit/data/repositories/photo_analysis_repository.dart';
import 'package:baiqavisit/domain/models/takephoto/taken_photo.dart';
import 'package:baiqavisit/domain/stream_controllers/take_photo_result_stream_controller.dart';
import 'package:baiqavisit/presentation/support/cubit/base_cubit.dart';
import 'package:camera/camera.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

part 'take_photo_cubit.freezed.dart';
part 'take_photo_state.dart';

@injectable
class TakePhotoCubit extends BaseCubit<TakePhotoState, TakePhotoEvent> {
  // final TakePhotoResultStreamController _takePhotoResultStreamController;
  // final PhotoAnalysisRepository _photoAnalysisRepository;


  TakePhotoCubit(
    // this._takePhotoResultStreamController,
    //   this._photoAnalysisRepository,
  ) : super(const TakePhotoState());

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
  //     emitEvent(TakePhotoEvent(TakePhotoEventType.openResultScreen));
  //
  //   })
  //   .onError((error){
  //     logger.d("TTT=> $error");
  //   })
  //   .onFinished((){})
  //   .executeFuture();
  // }


  void showPicture(bool isVisible) {
    emitEvent(TakePhotoEvent(TakePhotoEventType.onShowTakenPhoto));
  }

  void setTakenPhoto(XFile photo, String photoBase64) {
    updateState((state) => state.copyWith(
          takenPhotoFile: photo,
          takenPhotoInBase64: photoBase64,
        ));
  }


}





