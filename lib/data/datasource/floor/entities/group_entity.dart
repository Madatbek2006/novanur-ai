import 'package:floor/floor.dart';

@Entity(tableName: "groups")
class GroupEntity {
  @primaryKey
  @ColumnInfo(name: "group_id")
  int id;

  @ColumnInfo(name: "group_name")
  String name;

  @ColumnInfo(name: "group_student_count")
  int studentCount;

  @ColumnInfo(name: "group_auto_att_count")
  int autoAttCount;

  @ColumnInfo(name: "group_manual_att_count")
  int manualAttCount;

  @ColumnInfo(name: "group_spoofed_att_count")
  int spoofedAttCount;

  GroupEntity({
    required this.id,
    required this.name,
    required this.studentCount,
    required this.autoAttCount,
    required this.manualAttCount,
    required this.spoofedAttCount,
  });
}
