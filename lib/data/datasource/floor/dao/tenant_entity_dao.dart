import 'package:nurnova_ai/data/datasource/floor/entities/tenant_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class TenantEntityDao {
  @Query('SELECT * FROM tenant LIMIT 1 ')
  Future<TenantEntity?> readTenantInfo();

  @Query('SELECT * FROM tenant LIMIT 1 ')
  Stream<TenantEntity?> watchTenantInfo();

  // @transaction
  @Query('DELETE FROM tenant ')
  Future<void> clear();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insert(TenantEntity user);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> update(TenantEntity user);
}
