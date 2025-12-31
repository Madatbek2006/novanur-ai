import 'package:shared_preferences/shared_preferences.dart';

extension SharedPreferencesExts on SharedPreferences {
  Future<void> setOrRemove(String key, dynamic value) async {
    if (value == null) {
      await remove(key);
    } else if (value is int) {
      await setInt(key, value);
    } else if (value is double) {
      await setDouble(key, value);
    } else if (value is String) {
      await setString(key, value);
    } else if (value is bool) {
      await setBool(key, value);
    } else if (value is List<String>) {
      await setStringList(key, value);
    } else {
      throw ArgumentError("Unsupported value type on set SharedPreferences");
    }
  }
}
