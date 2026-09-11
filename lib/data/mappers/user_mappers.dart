import 'package:nurnova_ai/data/datasource/floor/entities/user_entity.dart';
import 'package:nurnova_ai/data/datasource/network/dto/auth/user/user_response.dart';
import 'package:nurnova_ai/domain/models/user/user.dart';

extension UserResponseMappers on UserResponse {
  UserEntity toEntity() {
    return UserEntity(
      userId: id,
      firstName: firstName ?? "",
      lastName: lastName ?? "",
      photo: photo ?? "",
      email: email ?? "",
      userRole: userRole ?? "",
    );
  }

  User toModel() {
    return User(
      id: id,
      firstName: firstName ?? "",
      lastName: lastName ?? "",
      fullName: "$firstName $lastName".trim(),
      email: email,
      photo: photo,
      userRole: userRole,
    );
  }
}

extension UserEntityMappers on UserEntity {
  User toModel() {
    return User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      fullName: "$firstName $lastName".trim(),
      email: email,
      photo: photo,
      userRole: userRole,
    );
  }
}
