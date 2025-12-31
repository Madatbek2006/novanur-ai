// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'processing_attendance_response.freezed.dart';
part 'processing_attendance_response.g.dart';

@freezed
class ProcessingAttendanceRootResponse with _$ProcessingAttendanceRootResponse {
  const factory ProcessingAttendanceRootResponse({
    @JsonKey(name: "attendances")
    List<ProcessingAttendanceResponse>? attendances,
  }) = _ProcessingAttendanceRootResponse;

  factory ProcessingAttendanceRootResponse.fromJson(
          Map<String, dynamic> json) =>
      _$ProcessingAttendanceRootResponseFromJson(json);
}

@freezed
class ProcessingAttendanceResponse with _$ProcessingAttendanceResponse {
  const factory ProcessingAttendanceResponse({
    @JsonKey(name: "device_id") String? deviceId,
    @JsonKey(name: "device_name") String? deviceName,
    @JsonKey(name: "attendance_photo") String? attendancePhoto,
    @JsonKey(name: "created_at") String? createdAt,
  }) = _ProcessingAttendanceResponse;

  factory ProcessingAttendanceResponse.fromJson(Map<String, dynamic> json) =>
      _$ProcessingAttendanceResponseFromJson(json);
}
