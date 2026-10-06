import 'package:nurnova_ai/data/datasource/preference/preferences_extensions.dart';
import 'package:nurnova_ai/data/datasource/preference/token_holder.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FcmTokenPreferences {
  final SharedPreferences _preferences;

  FcmTokenPreferences(this._preferences);

  static const String _keyFcmToken = "string_fcm_token";
  static const String _keyIsFcmTokenSent = "bool_is_fcm_token_sent";

  @factoryMethod
  static Future<FcmTokenPreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return FcmTokenPreferences(prefs);
  }

  bool get isFcmTokenTaken => _preferences.containsKey(_keyFcmToken);

  String get fcmToken => _preferences.getString(_keyFcmToken) ?? "";

  Future<void> setFcmToken(String fcmToken) async {
    await _preferences.setOrRemove(_keyFcmToken, fcmToken);
    await _preferences.setOrRemove(_keyIsFcmTokenSent, false);
    TokenHolder.fcmToken = fcmToken;
  }

  bool get isFcmTokenSent => _preferences.getBool(_keyIsFcmTokenSent) ?? false;

  bool get isFcmTokenNotSent => !isFcmTokenSent;

  Future<void> setIsFcmTokenSent(bool isFcmTokenSent) async =>
      await _preferences.setOrRemove(_keyIsFcmTokenSent, isFcmTokenSent);

  Future<void> clear() async {
    await _preferences.remove(_keyFcmToken);
    await _preferences.remove(_keyIsFcmTokenSent);
  }
}
