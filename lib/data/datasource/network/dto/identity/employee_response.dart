// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee_response.freezed.dart';
part 'employee_response.g.dart';

@freezed
class EmployeeRootResponse with _$EmployeeRootResponse {
  const factory EmployeeRootResponse({
    @JsonKey(name: "employees") List<EmployeeResponse>? employees,
  }) = _EmployeeRootResponse;

  factory EmployeeRootResponse.fromJson(Map<String, dynamic> json) =>
      _$EmployeeRootResponseFromJson(json);
}

@freezed
class EmployeeResponse with _$EmployeeResponse {
  const factory EmployeeResponse({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "iin") required String iin,
    @JsonKey(name: "first_name") String? firstName,
    @JsonKey(name: "last_name") String? lastName,
    @JsonKey(name: "patronymic_name") String? patronymicName,
    @JsonKey(name: "photo_path") String? identityPhoto,
    @JsonKey(name: "role") required String role,
    @JsonKey(name: "is_archived") bool? isArchived,
  }) = _EmployeeResponse;

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) =>
      _$EmployeeResponseFromJson(json);
}
