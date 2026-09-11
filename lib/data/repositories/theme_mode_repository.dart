import 'package:nurnova_ai/data/datasource/preference/theme_mode_preferences.dart';
import 'package:nurnova_ai/domain/models/theme/app_theme_mode.dart';

class ThemeModeRepository {
  final ThemeModePreferences _themeModePreferences;

  ThemeModeRepository(this._themeModePreferences);

  AppThemeMode getAppThemeMode() {
    return _themeModePreferences.appThemeMode;
  }

  Future<void> setAppThemeMode(AppThemeMode mode) async {
    return _themeModePreferences.setThemeMode(mode);
  }
}
