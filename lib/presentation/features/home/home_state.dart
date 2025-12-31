part of 'home_cubit.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(0) int notificationCount,
  }) = _HomeState;
}

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent(HomeEventType type) = _HomeEvent;
}

enum HomeEventType { onFcmTokenReceived }
