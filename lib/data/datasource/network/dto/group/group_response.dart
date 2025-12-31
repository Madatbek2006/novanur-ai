// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_response.freezed.dart';
part 'group_response.g.dart';

@freezed
class GroupRootResponse with _$GroupRootResponse {
  const factory GroupRootResponse({
    @JsonKey(name: "groups") required List<GroupResponse> data,
  }) = _GroupRootResponse;

  factory GroupRootResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupRootResponseFromJson(json);
}

@freezed
class GroupResponse with _$GroupResponse {
  const factory GroupResponse({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "name") String? name,
  }) = _GroupResponse;

  const GroupResponse._();

  factory GroupResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupResponseFromJson(json);
}
