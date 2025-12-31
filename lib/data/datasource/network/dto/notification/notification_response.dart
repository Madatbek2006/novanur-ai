// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_response.freezed.dart';
part 'notification_response.g.dart';

@freezed
class NotificationResponse with _$NotificationResponse {
  const factory NotificationResponse({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "title") String? title,
    @JsonKey(name: "body") String? body,
    @JsonKey(name: "device_id") String? deviceId,
    @JsonKey(name: "device_token") String? deviceToken,
    @JsonKey(name: "created_at") String? createdAt,
  }) = _NotificationResponse;

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);
}
