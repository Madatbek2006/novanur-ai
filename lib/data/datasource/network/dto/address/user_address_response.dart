// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_address_response.freezed.dart';
part 'user_address_response.g.dart';

@freezed
class UserAddressRootResponse with _$UserAddressRootResponse {
  const factory UserAddressRootResponse({
    dynamic error,
    dynamic message,
    dynamic timestamp,
    int? status,
    dynamic path,
    required List<UserAddressResponse> data,
    dynamic response,
  }) = _UserAddressRootResponse;

  factory UserAddressRootResponse.fromJson(Map<String, dynamic> json) =>
      _$UserAddressRootResponseFromJson(json);
}

@freezed
class UserAddressResponse with _$UserAddressResponse {
  const factory UserAddressResponse({
    required int id,
    @JsonKey(name: "region") UserAddressItemResponse? region,
    @JsonKey(name: "district") UserAddressItemResponse? district,
    @JsonKey(name: "mahalla") UserAddressItemResponse? neighborhood,
    @JsonKey(name: "state") int? state,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "street_num") String? streetName,
    @JsonKey(name: "home_num") String? houseNum,
    @JsonKey(name: "apartment_num") String? apartmentNum,
    @JsonKey(name: "geo") String? geo,
    @JsonKey(name: "is_main") bool? isMain,
  }) = _UserAddressResponse;

  const UserAddressResponse._();

  factory UserAddressResponse.fromJson(Map<String, dynamic> json) =>
      _$UserAddressResponseFromJson(json);
}

@freezed
class UserAddressItemResponse with _$UserAddressItemResponse {
  const factory UserAddressItemResponse({
    int? id,
    String? name,
  }) = _District;

  factory UserAddressItemResponse.fromJson(Map<String, dynamic> json) =>
      _$UserAddressItemResponseFromJson(json);
}
