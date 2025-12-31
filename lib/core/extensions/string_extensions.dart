import 'package:logger/logger.dart';

extension StringExtensions on String {
  String clearPhoneWithCode() {
    var clearedPhone = replaceAll(RegExp(r"[^\d+\.]"), '');
    if (clearedPhone.length == 9) {
      clearedPhone = "998$clearedPhone";
    }
    return clearedPhone;
  }

  String getFormattedPhoneNumber() {
    var clearedPhone = clearPhoneWithCode();

    String formattedNumber =
        '+${clearedPhone.substring(0, 3)} ${clearedPhone.substring(3, 5)} ${clearedPhone.substring(5, 8)} ${clearedPhone.substring(8, 10)} ${clearedPhone.substring(10)}';
    Logger().w(
        "this = $this, formatted = $formattedNumber, cleared = $clearedPhone");

    return formattedNumber;
  }

  String clearPhoneWithoutCode() {
    String countryCode = "998";
    if (length > 9 && contains(countryCode)) {
      return substring(countryCode.length);
    } else {
      return this;
    }
  }

  String clearPhoneNumber() {
    var clearedPhone = replaceAll(RegExp(r"[^\d+\.]"), '');
    return clearedPhone;
  }

  String clearPrice() {
    return replaceAll(RegExp(r"[^\d+\.]"), '');
  }

  String clearCharacters() {
    return replaceAll(RegExp(r"[^\d+\.]"), '');
  }

  String capitalizePersonName() {
    return trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String capitalizeCompanyName() {
    final RegExp quoteRegex = RegExp(r'"[^"]*"');
    final RegExp wordRegex = RegExp(r'\b\w+\b');

    return replaceAllMapped(quoteRegex, (quoteMatch) {
      return quoteMatch.group(0)!;
    }).replaceAllMapped(wordRegex, (wordMatch) {
      String word = wordMatch.group(0)!;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    });
  }
}