// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_response.freezed.dart';
part 'product_response.g.dart';

@freezed
class ProductRootResponse with _$ProductRootResponse {
  const factory ProductRootResponse({
    @JsonKey(name: 'status') required int status,
    @JsonKey(name: 'code') required String code,
    @JsonKey(name: 'status_verbose') String? statusVerbose,
    @JsonKey(name: 'product') ProductResponse? product,
  }) = _ProductRootResponse;

  factory ProductRootResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductRootResponseFromJson(json);
}

@freezed
class ProductResponse with _$ProductResponse {
  const factory ProductResponse({
    @JsonKey(name: 'product_name') String? productName,
    @JsonKey(name: 'brands') String? brands,
    @JsonKey(name: 'quantity') String? quantity,
    @JsonKey(name: 'categories') String? categories,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'ingredients_text') String? ingredientsText,
    @JsonKey(name: 'nutriments') Map<String, dynamic>? nutriments,
  }) = _ProductResponse;

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseFromJson(json);
}
