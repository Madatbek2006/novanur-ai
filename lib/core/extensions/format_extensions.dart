import 'package:baiqavisit/domain/models/language/language.dart';
import 'package:easy_localization/easy_localization.dart';

extension DoubleExtensions on double {
  double truncateToOneDecimal() {
    return (isNaN || isInfinite) ? 0 : (this * 10).truncateToDouble() / 10;
  }

  String formatNumber() {
    double truncated = (this * 10).truncateToDouble() / 10;

    if (truncated == truncated.toInt()) {
      return truncated.toInt().toString();
    } else {
      return truncated.toString();
    }
  }

  String formatDecimal() {
    try {
      final format = NumberFormat("0.##", Language.kazakhCyrill.getIdentifier());
      return format.format(this);
    } catch (e) {
      return toString();
    }
  }

  String formatWithSpace() {
    try {
      final formatter = NumberFormat.currency(
        locale: 'uz_UZ',
        decimalDigits: 2,
        symbol: '',
        customPattern: '#,##0.00',
      );

      // formatter.symbols.GROUP_SEP = ' ';
      // formatter.symbols.DECIMAL_SEP = '.';

      return formatter.format(this).trim();
    } catch (_) {
      return toStringAsFixed(2);
    }
  }
}

extension IntExtensions on int {
  /// Converts int to double then formats as decimal (0.##)
  String formatDecimal() {
    return toDouble().formatDecimal();
  }

  String formatWithSpace() {
    return toDouble().formatWithSpace();
  }
}