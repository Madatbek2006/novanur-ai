import 'package:floor/floor.dart';

Callback get databaseCallback => Callback(onCreate: (database, version) {
      // Called when the database is created for the first time.
    }, onUpgrade: (database, startVersion, endVersion) async {
      print("onUpgrade: $startVersion, $endVersion");
      // Called when the database needs to be upgraded.
    }, onOpen: (database) async {
      // Called when the database has been opened.
      print("onOpen");
    });
