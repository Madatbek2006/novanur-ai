import 'package:nurnova_ai/core/gen/localization/strings.dart';

class BirthDateValidator {
  static String? validate(String? value) {
    final clearedValue = value?.trim();
    if (clearedValue == null || clearedValue.trim().isEmpty) {
      return Strings.commonErrorFieldIsRequired;
    }

    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(clearedValue)) {
      return Strings.commonErrorBirthDateNotValid;
    }

    final date = DateTime.tryParse(clearedValue);
    if (date == null) {
      return Strings.commonErrorBirthDateNotValid;
    }
    final minDate = DateTime(1930);
    final maxDate = DateTime.now();
    if (date.isBefore(minDate) || date.isAfter(maxDate)) {
      return Strings.commonErrorBirthDateNotValid;
    }

    return null;
  }
}
