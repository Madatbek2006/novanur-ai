// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_response.freezed.dart';
part 'attendance_response.g.dart';

@freezed
class AttendanceRootResponse with _$AttendanceRootResponse {
  const factory AttendanceRootResponse({
    @JsonKey(name: "attendances") required List<AttendanceResponse> attendances,
    @JsonKey(name: "absents") required List<AbsentResponse> absents,
  }) = _AttendanceRootResponse;

  factory AttendanceRootResponse.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRootResponseFromJson(json);
}

@freezed
class AbsentResponse with _$AbsentResponse {
  const factory AbsentResponse({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "iin") required String iin,
    @JsonKey(name: "group") AttGroupResponse? group,
    @JsonKey(name: "first_name") String? firstName,
    @JsonKey(name: "last_name") String? lastName,
    @JsonKey(name: "patronymic_name") String? patronymicName,
    @JsonKey(name: "photo_path") String? identityPhoto,
    @JsonKey(name: "role") String? role,
    @JsonKey(name: "is_archived") bool? isArchived,
  }) = _AbsentResponse;

  factory AbsentResponse.fromJson(Map<String, dynamic> json) =>
      _$AbsentResponseFromJson(json);
}

@freezed
class AttendanceResponse with _$AttendanceResponse {
  const factory AttendanceResponse({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "iin") required String iin,
    @JsonKey(name: "group") AttGroupResponse? group,
    @JsonKey(name: "first_name") String? firstName,
    @JsonKey(name: "last_name") String? lastName,
    @JsonKey(name: "face_recogntion_path") String? attendancePhoto,
    @JsonKey(name: "face_actual_path") String? identityPhoto,
    @JsonKey(name: "face_image_sent_device") required String attTakingSource,
    @JsonKey(name: "is_spoofed") bool? isSpoofed,
    @JsonKey(name: "comp_score") double? compScore,
    @JsonKey(name: "spoofing_score") double? spoofingScore,
    @JsonKey(name: "created_at") String? createdAt,
  }) = _AttendanceResponse;

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) =>
      _$AttendanceResponseFromJson(json);
}

@freezed
class AttGroupResponse with _$AttGroupResponse {
  const factory AttGroupResponse({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "name") String? name,
  }) = _AttGroupResponse;

  factory AttGroupResponse.fromJson(Map<String, dynamic> json) =>
      _$AttGroupResponseFromJson(json);
}
