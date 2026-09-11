import 'package:nurnova_ai/data/datasource/preference/fcm_token_preferences.dart';
import 'package:nurnova_ai/data/datasource/preference/pin_code_preferences.dart';
import 'package:nurnova_ai/data/datasource/preference/tenant_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:nurnova_ai/data/datasource/preference/auth_preferences.dart';
import 'package:nurnova_ai/data/datasource/preference/language_preferences.dart';
import 'package:nurnova_ai/data/datasource/preference/theme_mode_preferences.dart';
import 'package:nurnova_ai/data/datasource/preference/user_preferences.dart';

extension GetItModulePreference on GetIt {
  Future<void> preferencesModule() async {
    registerSingletonAsync(() async => await AuthPreferences.create());
    registerSingletonAsync(() async => await PinCodePreferences.create());
    registerSingletonAsync(() async => await FcmTokenPreferences.create());
    registerSingletonAsync(() async => await LanguagePreferences.create());
    registerSingletonAsync(() async => await TenantPreferences.create());
    registerSingletonAsync(() async => await ThemeModePreferences.create());
    registerSingletonAsync(() async => await UserPreferences.create());
    await allReady();
  }
}
