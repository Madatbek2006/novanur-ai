import 'package:nurnova_ai/core/extensions/string_extensions.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';

class DocNumberValidator {
  static String? validate(String? value) {
    final clearedValue = value?.trim().clearCharacters();
    if (clearedValue == null || clearedValue.isEmpty) {
      return Strings.commonErrorFieldIsRequired;
    }

    if (!RegExp(r'^\d{7}$').hasMatch(clearedValue)) {
      return Strings.commonErrorDocNumberNotValid;
    }

    return null;
  }
}
