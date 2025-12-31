class Tenant {
  int id;
  String name;
  String description;
  double latitude;
  double longitude;
  double allowedRadius;
  String type;
  String address;
  int regionId;
  String regionName;
  int districtId;
  String districtName;
  String photoPath;
  int studentCount;
  int groupCount;
  int employeeCount;
  String createdAt;
  String updatedAt;

  Tenant({
    required this.id,
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
