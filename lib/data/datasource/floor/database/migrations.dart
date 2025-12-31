import 'package:floor/floor.dart';

final migration1to2 = Migration(1, 2, (database) async {
  await database.execute('''
    CREATE TABLE IF NOT EXISTS tenant (
      tenant_id INTEGER PRIMARY KEY AUTOINCREMENT,
      tenant_tenant_id INTEGER NOT NULL,
      tenant_name TEXT NOT NULL,
      tenant_description TEXT NOT NULL,
      tenant_latitude REAL NOT NULL,
      tenant_longitude REAL NOT NULL,
      tenant_allowed_radius REAL NOT NULL,
      tenant_type TEXT NOT NULL,
      tenant_address TEXT NOT NULL,
      tenant_region_id INTEGER NOT NULL,
      tenant_region_name TEXT NOT NULL,
      tenant_district_id INTEGER NOT NULL,
      tenant_district_name TEXT NOT NULL,
      tenant_photo_path TEXT NOT NULL,
      tenant_student_count INTEGER NOT NULL,
      tenant_group_count INTEGER NOT NULL,
      tenant_employee_count INTEGER NOT NULL,
      tenant_created_at TEXT NOT NULL,
      tenant_updated_at TEXT NOT NULL
    );
  ''');
});
