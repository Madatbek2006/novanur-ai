// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_att_stats_response.freezed.dart';
part 'group_att_stats_response.g.dart';

@freezed
class GroupAttStatsRootResponse with _$GroupAttStatsRootResponse {
  const factory GroupAttStatsRootResponse({
    @JsonKey(name: "groups") required List<GroupAttStatsResponse> data,
  }) = _GroupAttStatsRootResponse;

  factory GroupAttStatsRootResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupAttStatsRootResponseFromJson(json);
}

@freezed
class GroupAttStatsResponse with _$GroupAttStatsResponse {
  const factory GroupAttStatsResponse({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "total_student_count") int? studentCount,
    @JsonKey(name: "camera_attendance_count") int? autoAttCount,
    @JsonKey(name: "mobile_attendance_count") int? manualAttCount,
    @JsonKey(name: "spoofed_attendance_count") int? spoofedAttCount,
  }) = _GroupAttStatsResponse;

  const GroupAttStatsResponse._();

  factory GroupAttStatsResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupAttStatsResponseFromJson(json);
}
