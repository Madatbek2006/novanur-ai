part of 'dashboard_cubit.dart';

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState({
    DashboardButtonType? type,
    XFile? takenPhotoFile,
  }) = _DashboardState;
}

@freezed
class DashboardEvent with _$DashboardEvent {
  const factory DashboardEvent(DashboardEventType type) = _DashboardEvent;
}

enum DashboardEventType { onShowTakenPhoto, openResultScreen }
