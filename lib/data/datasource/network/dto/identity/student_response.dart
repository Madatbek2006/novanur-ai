// ignore_for_file: invalid_annotation_target

import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_response.freezed.dart';
part 'student_response.g.dart';

StudentRootResponse studentRootResponseFromJson(String str) =>
    StudentRootResponse.fromJson(json.decode(str));

String studentRootResponseToJson(StudentRootResponse data) =>
    json.encode(data.toJson());

@freezed
class StudentRootResponse with _$StudentRootResponse {
  const factory StudentRootResponse({
    @JsonKey(name: "students") List<StudentResponse>? students,
  }) = _StudentRootResponse;

  factory StudentRootResponse.fromJson(Map<String, dynamic> json) =>
      _$StudentRootResponseFromJson(json);
}

@freezed
class StudentResponse with _$StudentResponse {
  const factory StudentResponse({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "iin") required String iin,
    @JsonKey(name: "first_name") String? firstName,
    @JsonKey(name: "last_name") String? lastName,
    @JsonKey(name: "patronymic_name") String? patronymicName,
    @JsonKey(name: "photo_path") String? identityPhoto,
    @JsonKey(name: "group") StudentGroupResponse? group,
    @JsonKey(name: "is_archived") bool? isArchived,
  }) = _Student;

  factory StudentResponse.fromJson(Map<String, dynamic> json) =>
      _$StudentResponseFromJson(json);
}

@freezed
class StudentGroupResponse with _$StudentGroupResponse {
  const factory StudentGroupResponse({
    @JsonKey(name: "id") required int id,
    @JsonKey(name: "name") String? name,
  }) = _StudentGroupResponse;

  factory StudentGroupResponse.fromJson(Map<String, dynamic> json) =>
      _$StudentGroupResponseFromJson(json);
}
