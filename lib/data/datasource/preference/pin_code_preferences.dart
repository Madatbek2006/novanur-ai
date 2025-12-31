import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinCodePreferences {
  final SharedPreferences _preferences;

  PinCodePreferences(this._preferences);

  static const String _keyPinCode = "integer_pin_code";

  @factoryMethod
  static Future<PinCodePreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PinCodePreferences(prefs);
  }

  String get _pinCode => _preferences.getString(_keyPinCode) ?? "";

  Future<void> setPinCode(String pinCode) async {
    await _preferences.setString(_keyPinCode, pinCode);
  }

  bool validatePinCode(String pinCode) {
    return _pinCode == pinCode;
  }

  bool get isPinSet => _preferences.containsKey(_keyPinCode);

  bool get isPinNotSet => !isPinSet;

  Future<void> clear() async {
    await _preferences.remove(_keyPinCode);
  }
}
