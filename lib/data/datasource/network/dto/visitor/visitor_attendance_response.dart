// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'visitor_attendance_response.freezed.dart';
part 'visitor_attendance_response.g.dart';

@freezed
class VisitorAttendanceResponse with _$VisitorAttendanceResponse {
  const factory VisitorAttendanceResponse({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'gender') String? gender,
    @JsonKey(name: 'age') int? age,
    @JsonKey(name: 'face_recogntion_path') required String faceImage,
    @JsonKey(name: 'organization_name') String? orgName,
    @JsonKey(name: 'created_at') required DateTime recordedAt,
  }) = _VisitorAttendanceResponse;

  factory VisitorAttendanceResponse.fromJson(Map<String, dynamic> json) =>
      _$VisitorAttendanceResponseFromJson(json);
}
