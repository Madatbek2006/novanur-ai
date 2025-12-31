import 'package:baiqavisit/core/extensions/format_extensions.dart';

class GroupAttStats {
  int id;
  String name;
  int studentCount;
  int autoAttCount;
  int manualAttCount;
  int spoofedAttCount;

  GroupAttStats({
    required this.id,
    required this.name,
    required this.studentCount,
    required this.autoAttCount,
    required this.manualAttCount,
    required this.spoofedAttCount,
  });

  bool get hasStudent => studentCount > 0;

  int get totalAttCount => autoAttCount + manualAttCount;

  String get attPercent {
    double percent = hasStudent ? (totalAttCount / studentCount * 100) : 0;
    return percent.truncateToOneDecimal().formatNumber();
  }
}
