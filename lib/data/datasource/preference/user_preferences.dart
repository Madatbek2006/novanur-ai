import 'package:nurnova_ai/data/datasource/network/dto/auth/user/user_response.dart';
import 'package:nurnova_ai/data/datasource/preference/preferences_extensions.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  UserPreferences(this._preferences);

  final String _keyUserId = "integer_user_id";

  final String _keyUserFirstName = "string_user_first_name";
  final String _keyUserLastName = "string_user_last_name";
  final String _keyUserPhoto = "string_user_photo";

  final SharedPreferences _preferences;

  @FactoryMethod(preResolve: true)
  static Future<UserPreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return UserPreferences(prefs);
  }

  bool get isIdentified => true;

  bool get isNotIdentified => !isIdentified;

  int? get userId => _preferences.getInt(_keyUserId);

  int? get userName => _preferences.getInt(_keyUserFirstName);

  int? get userType => _preferences.getInt(_keyUserLastName);

  int? get tenantId => _preferences.getInt(_keyUserPhoto);

  Future<void> setUserInfo(UserResponse userResponse) async {
    await _preferences.setOrRemove(_keyUserId, userResponse.id);
    await _preferences.setOrRemove(_keyUserFirstName, userResponse.firstName);
    await _preferences.setOrRemove(_keyUserLastName, userResponse.lastName);
    await _preferences.setOrRemove(_keyUserPhoto, userResponse.photo);
  }

  Future<void> clear() async {
    await _preferences.remove(_keyUserId);
    await _preferences.remove(_keyUserFirstName);
    await _preferences.remove(_keyUserLastName);
    await _preferences.remove(_keyUserPhoto);
  }
}
