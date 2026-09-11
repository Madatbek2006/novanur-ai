import 'package:nurnova_ai/data/datasource/preference/preferences_extensions.dart';
import 'package:nurnova_ai/domain/models/theme/app_theme_mode.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModePreferences {
  final SharedPreferences _preferences;

  ThemeModePreferences(this._preferences);

  static const String _keyAppThemeMode = "string_app_theme_mode";

  @factoryMethod
  static Future<ThemeModePreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemeModePreferences(prefs);
  }

  String get appThemeModeName =>
      _preferences.getString(_keyAppThemeMode) ??
      AppThemeMode.followSystem.name;

  AppThemeMode get appThemeMode =>
      AppThemeMode.valueOrDefault(appThemeModeName);

  Future<void> setThemeMode(AppThemeMode mode) async =>
      await _preferences.setOrRemove(_keyAppThemeMode, mode.name);

  Future<void> clear() async => await _preferences.remove(_keyAppThemeMode);
}
