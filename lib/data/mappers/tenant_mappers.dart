import 'package:nurnova_ai/data/datasource/floor/entities/tenant_entity.dart';
import 'package:nurnova_ai/data/datasource/network/dto/tenant/tenant_response.dart';
import 'package:nurnova_ai/domain/models/tenant/tenant.dart';

extension TenantResponseMappers on TenantResponse {
  TenantEntity toEntity() {
    return TenantEntity(
      tenantId: id,
      name: name,
      description: description,
      latitude: latitude,
      longitude: longitude,
      allowedRadius: allowedRadius,
      type: type,
      address: address,
      regionId: region.id,
      regionName: region.name,
      districtId: district.id,
      districtName: district.name,
      photoPath: photoPath,
      studentCount: studentCount,
      groupCount: groupCount,
      employeeCount: employeeCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Tenant toModel() {
    return Tenant(
      id: id,
      name: name,
      description: description,
      latitude: latitude,
      longitude: longitude,
      allowedRadius: allowedRadius,
      type: type,
      address: address,
      regionId: region.id,
      regionName: region.name,
      districtId: district.id,
      districtName: district.name,
      photoPath: photoPath,
      studentCount: studentCount,
      groupCount: groupCount,
      employeeCount: employeeCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension TenantEntityMappers on TenantEntity {
  Tenant toModel() {
    return Tenant(
      id: id,
      name: name,
      description: description,
      latitude: latitude,
      longitude: longitude,
      allowedRadius: allowedRadius,
      type: type,
      address: address,
      regionId: regionId,
      regionName: regionName,
      districtId: districtId,
      districtName: districtName,
      photoPath: photoPath,
      studentCount: studentCount,
      groupCount: groupCount,
      employeeCount: employeeCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
