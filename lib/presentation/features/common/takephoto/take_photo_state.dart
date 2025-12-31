part of 'take_photo_cubit.dart';

@freezed
class TakePhotoState with _$TakePhotoState {
  const TakePhotoState._();

  const factory TakePhotoState({

    @Default(false) isSendingRequest,
//
    @Default(<CameraDescription>[]) List<CameraDescription> cameras,
    CameraController? cameraController,
//
    @Default(LoadingState.loading) LoadingState cameraInitState,
//
    XFile? takenPhotoFile,
    @Default("") String takenPhotoInBase64,
    @Default("") String title,
//
  }) = _TakePhotoState;


  bool get isCameraInitLoading => cameraInitState == LoadingState.loading;

  bool get isCameraInitFailed => cameraInitState == LoadingState.error;

  bool get isCameraVisible =>
      cameraInitState == LoadingState.success;
}

@freezed
class TakePhotoEvent with _$TakePhotoEvent {
  const factory TakePhotoEvent(TakePhotoEventType type) = _TakePhotoEvent;
}

enum TakePhotoEventType {
  onShowTakenPhoto,
  openResultScreen
}
