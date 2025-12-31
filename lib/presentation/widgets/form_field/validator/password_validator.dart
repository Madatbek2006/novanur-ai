import 'package:baiqavisit/core/gen/localization/strings.dart';

class PasswordValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.commonErrorFieldIsRequired;
    }

    final clearedValue = value;
    if (clearedValue.length < 6) {
      return Strings.commonErrorPassword;
    }

    return null;
  }
}
