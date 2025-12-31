// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification_response.freezed.dart';
part 'app_notification_response.g.dart';

@freezed
class AppNotificationRootResponse with _$AppNotificationRootResponse {
  const factory AppNotificationRootResponse({
    dynamic error,
    dynamic message,
    dynamic timestamp,
    int? status,
    dynamic path,
    required DataResponse data,
  }) = _AppNotificationRootResponse;

  factory AppNotificationRootResponse.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationRootResponseFromJson(json);
}

@freezed
class DataResponse with _$DataResponse {
  const factory DataResponse({
    @Default(0) @JsonKey(name: "count") int totalCount,
    @Default(0) @JsonKey(name: "unreads") int unreadCount,
    @JsonKey(name: "results") List<AppNotificationResponse>? results,
  }) = _DataResponse;

  factory DataResponse.fromJson(Map<String, dynamic> json) =>
      _$DataResponseFromJson(json);
}

@freezed
class AppNotificationResponse with _$AppNotificationResponse {
  const factory AppNotificationResponse({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "created_at") required String createdAt,
    @JsonKey(name: "tin") required int tinOrPinfl,
    @JsonKey(name: "title") required String title,
    @JsonKey(name: "note") required String message,
    @JsonKey(name: "link") String? link,
    @JsonKey(name: "status") required String status,
  }) = _AppNotificationResponse;

  factory AppNotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationResponseFromJson(json);
}
