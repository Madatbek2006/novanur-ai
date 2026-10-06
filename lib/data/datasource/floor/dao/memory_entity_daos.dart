import 'dart:async';

import 'package:nurnova_ai/data/datasource/floor/dao/group_entity_dao.dart';
import 'package:nurnova_ai/data/datasource/floor/dao/tenant_entity_dao.dart';
import 'package:nurnova_ai/data/datasource/floor/dao/user_entity_dao.dart';
import 'package:nurnova_ai/data/datasource/floor/entities/group_entity.dart';
import 'package:nurnova_ai/data/datasource/floor/entities/tenant_entity.dart';
import 'package:nurnova_ai/data/datasource/floor/entities/user_entity.dart';

/// In-memory DAOs for the web build, where sqflite (and so floor) is unavailable.

class MemoryGroupEntityDao implements GroupEntityDao {
  final Map<int, GroupEntity> _groups = {};
  final _changes = StreamController<List<GroupEntity>>.broadcast();

  List<GroupEntity> get _sorted =>
      _groups.values.toList()..sort((a, b) => a.name.compareTo(b.name));

  void _notify() => _changes.add(_sorted);

  @override
  Future<List<GroupEntity>> readGroups() async => _sorted;

  @override
  Stream<List<GroupEntity>> watchGroups() async* {
    yield _sorted;
    yield* _changes.stream;
  }

  @override
  Future<int?> readGroupCount() async => _groups.length;

  @override
  Future<void> clear() async {
    _groups.clear();
    _notify();
  }

  @override
  Future<int> insert(GroupEntity group) async {
    _groups[group.id] = group;
    _notify();
    return group.id;
  }

  @override
  Future<void> insertAll(List<GroupEntity> groups) async {
    for (final group in groups) {
      _groups[group.id] = group;
    }
    _notify();
  }

  @override
  Future<void> update(GroupEntity group) => insert(group);

  @override
  Future<void> updateAll(List<GroupEntity> groups) => insertAll(groups);
}

class MemoryTenantEntityDao implements TenantEntityDao {
  TenantEntity? _tenant;
  final _changes = StreamController<TenantEntity?>.broadcast();

  @override
  Future<TenantEntity?> readTenantInfo() async => _tenant;

  @override
  Stream<TenantEntity?> watchTenantInfo() async* {
    yield _tenant;
    yield* _changes.stream;
  }

  @override
  Future<void> clear() async {
    _tenant = null;
    _changes.add(null);
  }

  @override
  Future<void> insert(TenantEntity user) async {
    _tenant = user;
    _changes.add(user);
  }

  @override
  Future<void> update(TenantEntity user) => insert(user);
}

class MemoryUserEntityDao implements UserEntityDao {
  UserEntity? _user;
  final _changes = StreamController<UserEntity?>.broadcast();

  @override
  Future<UserEntity?> readUser() async => _user;

  @override
  Stream<UserEntity?> watchUser() async* {
    yield _user;
    yield* _changes.stream;
  }

  @override
  Future<void> clear() async {
    _user = null;
    _changes.add(null);
  }

  @override
  Future<void> insert(UserEntity user) async {
    _user = user;
    _changes.add(user);
  }

  @override
  Future<void> update(UserEntity user) => insert(user);
}
