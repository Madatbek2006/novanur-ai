import 'package:baiqavisit/core/gen/localization/strings.dart';

class DocSeriesValidator {
  static String? validate(String? value) {
    final clearedValue = value?.trim();
    if (clearedValue == null || clearedValue.isEmpty) {
      return Strings.commonErrorFieldIsRequired;
    }

    if (!RegExp(r'^[A-Z]{2}$').hasMatch(clearedValue)) {
      return Strings.commonErrorDocSeriesNotValid;
    }

    return null;
  }
}
