part of 'dashboard_cubit.dart';

@freezed
class DashboardState with _$DashboardState {
  const DashboardState._();

  const factory DashboardState({

    @Default(false) isSendingRequest,
//
    @Default(<CameraDescription>[]) List<CameraDescription> cameras,
    CameraController? cameraController,
    DashboardButtonType? type,
//
    @Default(LoadingState.loading) LoadingState cameraInitState,
//
    XFile? takenPhotoFile,
    @Default("") String takenPhotoInBase64,
    @Default("") String title,
//
  }) = _DashboardState;


  bool get isCameraInitLoading => cameraInitState == LoadingState.loading;

  bool get isCameraInitFailed => cameraInitState == LoadingState.error;

  bool get isCameraVisible =>
      cameraInitState == LoadingState.success;
}

@freezed
class DashboardEvent with _$DashboardEvent {
  const factory DashboardEvent(DashboardEventType type) = _DashboardEvent;
}

enum DashboardEventType {
  onShowTakenPhoto,
  openResultScreen
}
