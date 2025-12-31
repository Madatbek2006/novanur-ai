// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_response.freezed.dart';
part 'token_response.g.dart';

@freezed
class TokenResponse with _$TokenResponse {
  const factory TokenResponse({
    @JsonKey(name: "access_token") required String accessToken,
    @JsonKey(name: "refresh_token") String? refreshToken,
    @JsonKey(name: "token_type") required String tokenType,
    @JsonKey(name: "access_role") required String accessRole,
  }) = _TokenResponse;

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);
}
