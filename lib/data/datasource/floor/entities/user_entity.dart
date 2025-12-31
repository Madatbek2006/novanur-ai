import 'package:floor/floor.dart';

@Entity(tableName: "users")
class UserEntity {
  @PrimaryKey(autoGenerate: true)
  @ColumnInfo(name: "user_id")
  int id;

  @ColumnInfo(name: "user_user_id")
  int userId;

  @ColumnInfo(name: "user_first_name")
  String firstName;

  @ColumnInfo(name: "user_last_name")
  String lastName;

  @ColumnInfo(name: "user_photo")
  String photo;

  @ColumnInfo(name: "user_email")
  String email;

  @ColumnInfo(name: "user_role")
  String userRole;

  UserEntity({
    this.id = 0,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.photo,
    required this.email,
    required this.userRole,
  });
}
