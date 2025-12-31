import 'package:baiqavisit/core/gen/localization/strings.dart';

class CountValidator {
  static String? validate(int? value) {
    if (value == null || value <= 0) {
      return Strings.commonErrorFieldIsRequired;
    }

    return null;
  }
}
