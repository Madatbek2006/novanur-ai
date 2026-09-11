import 'package:nurnova_ai/data/datasource/floor/entities/group_entity.dart';
import 'package:nurnova_ai/data/datasource/network/dto/group/group_att_stats_response.dart';
import 'package:nurnova_ai/data/datasource/network/dto/group/group_response.dart';
import 'package:nurnova_ai/domain/models/group/group.dart';
import 'package:nurnova_ai/domain/models/group/group_att_stats.dart';

extension GroupAttStatsResponseMapper on GroupAttStatsResponse {
  GroupEntity toEntity() {
    return GroupEntity(
      id: id,
      name: name ?? "",
      studentCount: studentCount ?? 0,
      autoAttCount: autoAttCount ?? 0,
      manualAttCount: manualAttCount ?? 0,
      spoofedAttCount: spoofedAttCount ?? 0,
    );
  }

  GroupAttStats toModel() {
    return GroupAttStats(
      id: id,
      name: name ?? "",
      studentCount: studentCount ?? 0,
      autoAttCount: autoAttCount ?? 0,
      manualAttCount: manualAttCount ?? 0,
      spoofedAttCount: spoofedAttCount ?? 0,
    );
  }
}

extension GroupEntityMapper on GroupEntity {
  GroupAttStats toModel() {
    return GroupAttStats(
      id: id,
      name: name,
      studentCount: studentCount,
      autoAttCount: autoAttCount,
      manualAttCount: manualAttCount,
      spoofedAttCount: spoofedAttCount,
    );
  }
}

extension GroupResponseMapper on GroupResponse {
  Group toModel() {
    return Group(
      id: id,
      name: name ?? "",
    );
  }
}
