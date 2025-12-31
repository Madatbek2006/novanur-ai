// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification_count_response.freezed.dart';
part 'app_notification_count_response.g.dart';

@freezed
class AppNotificationCountRootResponse with _$AppNotificationCountRootResponse {
  const factory AppNotificationCountRootResponse({
    dynamic error,
    dynamic message,
    dynamic timestamp,
    int? status,
    dynamic path,
    required DataResponse data,
  }) = _AppNotificationCountRootResponse;

  factory AppNotificationCountRootResponse.fromJson(
          Map<String, dynamic> json) =>
      _$AppNotificationCountRootResponseFromJson(json);
}

@freezed
class DataResponse with _$DataResponse {
  const factory DataResponse({
    @JsonKey(name: "count") int? unreadCount,
  }) = _DataResponse;

  factory DataResponse.fromJson(Map<String, dynamic> json) =>
      _$DataResponseFromJson(json);
}
