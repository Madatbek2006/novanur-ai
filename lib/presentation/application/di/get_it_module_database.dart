import 'package:nurnova_ai/data/datasource/floor/dao/group_entity_dao.dart';
import 'package:nurnova_ai/data/datasource/floor/dao/tenant_entity_dao.dart';
import 'package:nurnova_ai/data/datasource/floor/dao/user_entity_dao.dart';
import 'package:nurnova_ai/data/datasource/floor/database/app_database.dart';
import 'package:get_it/get_it.dart';

extension GetItModuleDatabase on GetIt {
  Future<void> databaseModule() async {
    registerSingletonAsync<AppDatabase>(
      () async => await AppDatabase.initializeDatabase(),
    );

    registerSingletonWithDependencies<GroupEntityDao>(
      () => get<AppDatabase>().groupEntityDao,
      dependsOn: [AppDatabase],
    );
    registerSingletonWithDependencies<TenantEntityDao>(
      () => get<AppDatabase>().tenantEntityDao,
      dependsOn: [AppDatabase],
    );
    registerSingletonWithDependencies<UserEntityDao>(
      () => get<AppDatabase>().userEntityDao,
      dependsOn: [AppDatabase],
    );

    await allReady();
  }
}
