import 'package:baiqavisit/data/datasource/floor/entities/group_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class GroupEntityDao {
  @Query("SELECT * FROM groups ORDER BY group_name ASC")
  Future<List<GroupEntity>> readGroups();

  @Query("SELECT * FROM groups ORDER BY group_name ASC")
  Stream<List<GroupEntity>> watchGroups();

  @Query('SELECT COUNT(*) FROM groups ')
  Future<int?> readGroupCount();

  // @transaction
  @Query('DELETE FROM groups ')
  Future<void> clear();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insert(GroupEntity group);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<GroupEntity> groups);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> update(GroupEntity group);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateAll(List<GroupEntity> groups);
}
