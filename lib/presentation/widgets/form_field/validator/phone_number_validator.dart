import 'package:baiqavisit/core/extensions/string_extensions.dart';
import 'package:baiqavisit/core/gen/localization/strings.dart';

class PhoneNumberValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.commonErrorFieldIsRequired;
    }

    final clearedValue = value.clearPhoneNumber();
    if (clearedValue.length != 9) {
      return Strings.commonErrorPhoneNotValid;
    }

    return null;
  }
}
