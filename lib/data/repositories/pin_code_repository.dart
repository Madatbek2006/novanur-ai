import 'dart:async';

import 'package:nurnova_ai/data/datasource/preference/pin_code_preferences.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class PinCodeRepository {
  final PinCodePreferences _pinCodePreferences;

  PinCodeRepository(this._pinCodePreferences);

  Future<void> savePinCode(String pinCode) async {
    await _pinCodePreferences.setPinCode(pinCode);
  }

  bool validatePinCode(String enteredPin) {
    return _pinCodePreferences.validatePinCode(enteredPin);
  }

  bool get isPinSet => _pinCodePreferences.isPinSet;
}