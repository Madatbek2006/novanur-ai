import 'dart:async';
import 'dart:io';

import 'package:nurnova_ai/data/datasource/floor/dao/group_entity_dao.dart';
import 'package:nurnova_ai/data/datasource/floor/dao/tenant_entity_dao.dart';
import 'package:nurnova_ai/data/datasource/floor/dao/user_entity_dao.dart';
import 'package:nurnova_ai/data/datasource/floor/database/callback.dart';
import 'package:nurnova_ai/data/datasource/floor/database/migrations.dart';
import 'package:nurnova_ai/data/datasource/floor/entities/group_entity.dart';
import 'package:nurnova_ai/data/datasource/floor/entities/tenant_entity.dart';
import 'package:nurnova_ai/data/datasource/floor/entities/user_entity.dart';
import 'package:floor/floor.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@Database(
  entities: [
    GroupEntity,
    TenantEntity,
    UserEntity,
  ],
  version: 2,
)
abstract class AppDatabase extends FloorDatabase {
  GroupEntityDao get groupEntityDao;
  TenantEntityDao get tenantEntityDao;
  UserEntityDao get userEntityDao;

  static Future<AppDatabase> initializeDatabase() async {
    final migrations = [migration1to2];
    try {
      final database = await $FloorAppDatabase
          .databaseBuilder("app_database.db")
          .addCallback(databaseCallback)
          .addMigrations(migrations)
          .build();

      return database;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> deleteDatabaseFile(String databaseName) async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(directory.path, databaseName);

    if (await File(dbPath).exists()) {
      await File(dbPath).delete();
      print("Deleted old database: $dbPath");
    }
  }
}
