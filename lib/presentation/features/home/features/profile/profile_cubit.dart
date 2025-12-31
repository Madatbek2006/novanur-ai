import 'dart:async';

import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/data/repositories/language_repository.dart';
import 'package:baiqavisit/data/repositories/theme_mode_repository.dart';
import 'package:baiqavisit/domain/models/language/language.dart';
import 'package:baiqavisit/domain/models/logout/logout_event.dart';
import 'package:baiqavisit/domain/models/tenant/tenant.dart';
import 'package:baiqavisit/domain/models/theme/app_theme_mode.dart';
import 'package:baiqavisit/domain/models/user/user.dart';
import 'package:baiqavisit/domain/stream_controllers/app_theme_mode_stream_controller.dart';
import 'package:baiqavisit/domain/stream_controllers/language_selection_stream_controller.dart';
import 'package:baiqavisit/domain/stream_controllers/logout_event_stream_controller.dart';
import 'package:baiqavisit/presentation/support/cubit/base_cubit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_cubit.freezed.dart';
part 'profile_state.dart';

class ProfileCubit extends BaseCubit<ProfileState, ProfileEvent> {
  final AppThemeModeStreamController _appThemeModeStreamController;
  final LanguageRepository _languageRepository;
  final LanguageSelectionStreamController _languageSelectionStreamController;
  final LogoutEventStreamController _logoutEventStreamController;
  final ThemeModeRepository _themeModeRepository;

  ProfileCubit(
    this._appThemeModeStreamController,
    this._languageRepository,
    this._languageSelectionStreamController,
    this._logoutEventStreamController,
    this._themeModeRepository,
  ) : super(ProfileState()) {

    _getLanguage();
    _getThemeMode();
  }




  void _getLanguage() async {
    final language = _languageRepository.getLanguage();
    updateState((state) => state.copyWith(language: language));
  }

  void _getThemeMode() async {
    final mode = _themeModeRepository.getAppThemeMode();
    updateState((state) => state.copyWith(appThemeMode: mode));
  }

  void setSelectedLanguage(Language language) async {
    updateState((state) => state.copyWith(language: language));
    await _languageRepository.setLanguage(language);

    _languageSelectionStreamController.add(language);
  }

  void setSelectedThemeMode(AppThemeMode mode) async {
    await _themeModeRepository.setAppThemeMode(mode);
    updateState((state) => state.copyWith(appThemeMode: mode));
    _appThemeModeStreamController.add(mode);
  }

  void changePinCode() {
    emitEvent(const ProfileEvent(ProfileEventType.onChangePinCode));
  }

  void changePassword() {
    emitEvent(const ProfileEvent(ProfileEventType.onChangePassword));
  }

  Future<void> logOut() async {
    try {
      logger.w("logOut call");
      _logoutEventStreamController.add(LogoutEvent.onLogoutFromUI);

      emitEvent(ProfileEvent(ProfileEventType.onLogOut));
    } catch (e) {
      stateMessageManager.showErrorSnackBar(Strings.commonEmptyMessage);
    }
  }
}
