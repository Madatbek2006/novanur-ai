// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant_response.freezed.dart';
part 'tenant_response.g.dart';

@freezed
class TenantResponse with _$TenantResponse {
  const factory TenantResponse({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "name") required String name,
    @JsonKey(name: "description") required String description,
    @JsonKey(name: "latitude") required double latitude,
    @JsonKey(name: "longitude") required double longitude,
    @JsonKey(name: "allowed_radius") required double allowedRadius,
    @JsonKey(name: "type") required String type,
    @JsonKey(name: "address") required String address,
    @JsonKey(name: "region") required Region region,
    @JsonKey(name: "district") required District district,
    @JsonKey(name: "photo_path") required String photoPath,
    @JsonKey(name: "student_count") required int studentCount,
    @JsonKey(name: "group_count") required int groupCount,
    @JsonKey(name: "employee_count") required int employeeCount,
    @JsonKey(name: "created_at") required String createdAt,
    @JsonKey(name: "updated_at") required String updatedAt,
  }) = _TenantResponse;

  factory TenantResponse.fromJson(Map<String, dynamic> json) =>
      _$TenantResponseFromJson(json);
}

@freezed
class District with _$District {
  const factory District({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "name") required String name,
  }) = _District;

  factory District.fromJson(Map<String, dynamic> json) =>
      _$DistrictFromJson(json);
}

@freezed
class Region with _$Region {
  const factory Region({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "name") required String name,
  }) = _Region;

  factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);
}
