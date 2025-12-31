// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_stats_response.freezed.dart';
part 'attendance_stats_response.g.dart';

@freezed
class AttendanceStatsResponse with _$AttendanceStatsResponse {
  const factory AttendanceStatsResponse({
    @JsonKey(name: "camera_attendance_count") int? autoAttCount,
    @JsonKey(name: "mobile_attendance_count") int? manualAttCount,
    @JsonKey(name: "spoofed_attendance_count") int? spoofedAttCount,
    @JsonKey(name: "total_attendance_count") int? totalAttCount,
    @JsonKey(name: "absent_count") int? totalAbsentCount,
  }) = _AttendanceStatsResponse;

  factory AttendanceStatsResponse.fromJson(Map<String, dynamic> json) =>
      _$AttendanceStatsResponseFromJson(json);
}
