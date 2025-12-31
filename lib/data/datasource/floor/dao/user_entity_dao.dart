import 'package:baiqavisit/data/datasource/floor/entities/user_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class UserEntityDao {
  @Query('SELECT * FROM users LIMIT 1 ')
  Future<UserEntity?> readUser();

  @Query('SELECT * FROM users LIMIT 1 ')
  Stream<UserEntity?> watchUser();

  @Query('DELETE FROM users ')
  Future<void> clear();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insert(UserEntity user);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> update(UserEntity user);
}
