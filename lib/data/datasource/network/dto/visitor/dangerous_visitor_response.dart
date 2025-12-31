// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'dangerous_visitor_response.freezed.dart';
part 'dangerous_visitor_response.g.dart';

@freezed
class DangerousVisitorResponse with _$DangerousVisitorResponse {
  const factory DangerousVisitorResponse({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'iin') String? iin,
    @JsonKey(name: 'group') Map<String, dynamic>? group,
    @JsonKey(name: 'face_actual_path') String? actualFaceImage,
    @JsonKey(name: 'face_recogntion_path') String? recognitionFaceImage,
    @JsonKey(name: 'face_image_sent_device') String? faceImageSentDevice,
    @JsonKey(name: 'is_spoofed') double? isSpoofed,
    @JsonKey(name: 'comp_score') double? compScore,
    @JsonKey(name: 'spoofing_score') double? spoofingScore,
    @JsonKey(name: 'created_at') required DateTime recordedAt,
  }) = _DangerousVisitorResponse;

  factory DangerousVisitorResponse.fromJson(Map<String, dynamic> json) =>
      _$DangerousVisitorResponseFromJson(json);
}
