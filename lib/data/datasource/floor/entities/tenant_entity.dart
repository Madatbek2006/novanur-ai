import 'package:floor/floor.dart';

@Entity(tableName: "tenant")
class TenantEntity {
  @PrimaryKey(autoGenerate: true)

  @ColumnInfo(name: "tenant_id")
  int id;

  @ColumnInfo(name: "tenant_tenant_id")
  int tenantId;

  @ColumnInfo(name: "tenant_name")
  String name;

  @ColumnInfo(name: "tenant_description")
  String description;

  @ColumnInfo(name: "tenant_latitude")
  double latitude;

  @ColumnInfo(name: "tenant_longitude")
  double longitude;

  @ColumnInfo(name: "tenant_allowed_radius")
  double allowedRadius;

  @ColumnInfo(name: "tenant_type")
  String type;

  @ColumnInfo(name: "tenant_address")
  String address;

  @ColumnInfo(name: "tenant_region_id")
  int regionId;

  @ColumnInfo(name: "tenant_region_name")
  String regionName;

  @ColumnInfo(name: "tenant_district_id")
  int districtId;

  @ColumnInfo(name: "tenant_district_name")
  String districtName;

  @ColumnInfo(name: "tenant_photo_path")
  String photoPath;

  @ColumnInfo(name: "tenant_student_count")
  int studentCount;

  @ColumnInfo(name: "tenant_group_count")
  int groupCount;

  @ColumnInfo(name: "tenant_employee_count")
  int employeeCount;

  @ColumnInfo(name: "tenant_created_at")
  String createdAt;

  @ColumnInfo(name: "tenant_updated_at")
  String updatedAt;

  TenantEntity({
    this.id = 0,
    required this.tenantId,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.allowedRadius,
    required this.type,
    required this.address,
    required this.regionId,
    required this.regionName,
    required this.districtId,
    required this.districtName,
    required this.photoPath,
    required this.studentCount,
    required this.groupCount,
    required this.employeeCount,
    required this.createdAt,
    required this.updatedAt,
  });
}
