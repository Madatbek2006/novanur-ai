import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

extension DateExtensions on DateTime {
  String toDateString({String format = 'yyyy-MM-dd'}) {
    return DateFormat(format, 'uz').format(this);
  }

  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isSameDay(DateTime date) {
    return year == date.year && month == date.month && day == date.day;
  }

  DateTime startOfDay() => DateTime(year, month, day);

  DateTime endOfDay() => DateTime(year, month, day, 23, 59, 59, 999);

  DateTime startOfBeforeDay() {
    final yesterday = subtract(const Duration(days: 1));
    return DateTime(yesterday.year, yesterday.month, yesterday.day);
  }

  DateTime endOfBeforeDay() {
    final yesterday = subtract(const Duration(days: 1));
    return DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59, 999);
  }

  DateTime startOfNextDay() {
    final tomorrow = add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
  }

  DateTime endOfNextDay() {
    final tomorrow = add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59, 59, 999);
  }
}

extension IntDateExtensions on int {
  String toDateString({String format = 'yyyy-MM-dd'}) {
    return DateTime.fromMillisecondsSinceEpoch(this)
        .toDateString(format: format);
  }
}

bool isValidDate(String dateString, String format) {
  try {
    final dateFormat = DateFormat(format);
    dateFormat.parseStrict(dateString);
    return true;
  } catch (_) {
    return false;
  }
}

extension StringDateExtensions on String {
  DateTime toDate(String format) {
    return DateFormat(format).parse(this);
  }

  bool isValidDate(String format) {
    try {
      final dateFormat = DateFormat(format);
      dateFormat.parseStrict(this);
      return true;
    } catch (_) {
      return false;
    }
  }

  String changeDateFormat(String fromFormat, String toFormat) {
    try {
      // final dateFormat = DateFormat(fromFormat);
      // final date = dateFormat.parseStrict(this);
      final date = DateTime.tryParse(this);
      if (date == null) {
        return this;
      }
      return DateFormat(toFormat).format(date);
    } catch (e) {
      Logger().e(e);
      return this;
    }
  }
}
