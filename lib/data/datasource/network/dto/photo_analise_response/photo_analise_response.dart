// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_analise_response.freezed.dart';
part 'photo_analise_response.g.dart';

@freezed
class PhotoAnaliseRootResponse with _$PhotoAnaliseRootResponse {
  const factory PhotoAnaliseRootResponse({
    required List<PhotoAnaliseDetailResponse> detail,
  }) = _PhotoAnaliseRootResponse;

  factory PhotoAnaliseRootResponse.fromJson(Map<String, dynamic> json) =>
      _$PhotoAnaliseRootResponseFromJson(json);
}

@freezed
class PhotoAnaliseDetailResponse with _$PhotoAnaliseDetailResponse {
  const factory PhotoAnaliseDetailResponse({
    required List<dynamic> loc,
    String? msg,
    String? type,
  }) = _PhotoAnaliseDetailResponse;

  factory PhotoAnaliseDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$PhotoAnaliseDetailResponseFromJson(json);
}
