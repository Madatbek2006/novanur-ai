import 'package:nurnova_ai/core/gen/localization/strings.dart';

class NotEmptyValidator {
  static String? validate(String? value) {
    String? errorMessage;
    if (value == null || value.trim().isEmpty) {
      errorMessage = Strings.commonErrorFieldIsRequired;
    }

    // Logger().w("value for validate = $value, error = $errorMessage");
    return errorMessage;
  }
}
