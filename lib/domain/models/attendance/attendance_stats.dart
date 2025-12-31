import 'package:baiqavisit/core/extensions/format_extensions.dart';

class AttendanceStats {
  int autoAttCount;
  int manualAttCount;
  int spoofedAttCount;
  int totalAttCount;
  int totalAbsentCount;
  bool isEmployeeStats;

  AttendanceStats({
    required this.autoAttCount,
    required this.manualAttCount,
    required this.spoofedAttCount,
    required this.totalAttCount,
    required this.totalAbsentCount,
    required this.isEmployeeStats,
  });

  int get totalIdentityCount => totalAttCount + totalAbsentCount;

  bool get hasData => totalIdentityCount > 0;

  String get autoAttPercent => _calculatePercentage(autoAttCount);

  String get manualAttPercent => _calculatePercentage(manualAttCount);

  String get spoofedAttPercent => _calculatePercentage(spoofedAttCount);

  String get totalAbsentPercent => _calculatePercentage(totalAbsentCount);

  String _calculatePercentage(int count) {
    if (totalIdentityCount <= 0 || count.isNaN || count.isInfinite) {
      return "0%";
    }
    double percent = (count / totalIdentityCount) * 100;
    return "${percent.truncateToOneDecimal().formatNumber()}%";
  }
}
