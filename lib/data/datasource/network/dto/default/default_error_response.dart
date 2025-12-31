// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'default_error_response.freezed.dart';
part 'default_error_response.g.dart';

@freezed
class DefaultErrorResponse with _$DefaultErrorResponse {
  const DefaultErrorResponse._();

  const factory DefaultErrorResponse({
    @JsonKey(name: "detail") String? detailMessage,
  }) = _DefaultErrorResponse;

  bool get hasDetailMessage => detailMessage != null && detailMessage!.isNotEmpty;

  factory DefaultErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$DefaultErrorResponseFromJson(json);
}
