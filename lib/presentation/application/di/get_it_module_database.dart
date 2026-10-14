import 'package:nurnova_ai/data/datasource/floor/dao/group_entity_dao.dart';
import 'package:nurnova_ai/data/datasource/floor/dao/memory_entity_daos.dart';
import 'package:nurnova_ai/data/datasource/floor/dao/tenant_entity_dao.dart';
import 'package:nurnova_ai/data/datasource/floor/dao/user_entity_dao.dart';
import 'package:nurnova_ai/data/datasource/floor/database/app_database.dart';
import 'package:get_it/get_it.dart';
import 'package:nurnova_ai/core/platform/app_platform.dart';

extension GetItModuleDatabase on GetIt {
  Future<void> databaseModule() async {
    if (usesWebLayout) {
      // sqflite has no browser implementation, and on a computer it would
      // need sqflite_common_ffi; the site and the desktop app keep the same
      // in-memory tables.
      registerSingleton<GroupEntityDao>(MemoryGroupEntityDao());
      registerSingleton<TenantEntityDao>(MemoryTenantEntityDao());
      registerSingleton<UserEntityDao>(MemoryUserEntityDao());
      return;
    }

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
