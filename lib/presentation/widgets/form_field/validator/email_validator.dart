import 'package:baiqavisit/core/gen/localization/strings.dart';

class EmailValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.commonErrorFieldIsRequired;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return Strings.commonErrorEmailNotValid;
    }

    return null;
  }
}
