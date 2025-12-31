part of 'profile_cubit.dart';

@freezed
class ProfileState with _$ProfileState {
  const ProfileState._();

  const factory ProfileState({
//
    User? user,
//
    Tenant? tenant,
//
    Language? language,
//
    AppThemeMode? appThemeMode,
//
  }) = _ProfileState;

  String get userFullName => user?.fullName ?? "";

  String get userPhoto => user?.photo ?? "";

  String get tenantName => tenant?.name ?? "";

  String get tenantPhoto => tenant?.photoPath ?? "";

  String get tenantAddress => tenant?.address ?? "";
}

@freezed
class ProfileEvent with _$ProfileEvent {
  const factory ProfileEvent(ProfileEventType type) = _ProfileEvent;
}

enum ProfileEventType {
  onLogOut,
  onTokenExpired,
  onChangePinCode,
  onChangePassword,
}
