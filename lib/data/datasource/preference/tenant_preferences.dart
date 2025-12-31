import 'package:baiqavisit/data/datasource/network/dto/tenant/tenant_response.dart';
import 'package:baiqavisit/data/datasource/preference/preferences_extensions.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TenantPreferences {
  TenantPreferences(this._preferences);

  final String _keyTenantId = "integer_tenant_id";

  final String _keyTenantName = "string_tenant_name";
  final String _keyTenantType = "string_tenant_type";
  final String _keyTenantPhoto = "string_tenant_photo";

  final String _keyTenantLat = "double_tenant_lat";
  final String _keyTenantLng = "double_tenant_lng";
  final String _keyAllowedRadius = "double_tenant_allowed_radius";

  final SharedPreferences _preferences;

  @FactoryMethod(preResolve: true)
  static Future<TenantPreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TenantPreferences(prefs);
  }

  int? get tenantId => _preferences.getInt(_keyTenantId);

  int? get tenantName => _preferences.getInt(_keyTenantName);

  int? get tenantType => _preferences.getInt(_keyTenantType);

  int? get tenantPhoto => _preferences.getInt(_keyTenantPhoto);

  double? get tenantLat => _preferences.getDouble(_keyTenantLat);

  double? get tenantLng => _preferences.getDouble(_keyTenantLng);

  double? get tenantAllowingRadius => _preferences.getDouble(_keyAllowedRadius);

  Future<void> setTenantInfo(TenantResponse tenant) async {
    await _preferences.setOrRemove(_keyTenantId, tenant.id);

    await _preferences.setOrRemove(_keyTenantName, tenant.name);
    await _preferences.setOrRemove(_keyTenantType, tenant.type);
    await _preferences.setOrRemove(_keyTenantPhoto, tenant.photoPath);

    await _preferences.setOrRemove(_keyTenantLat, tenant.latitude);
    await _preferences.setOrRemove(_keyTenantLng, tenant.longitude);
    await _preferences.setOrRemove(_keyAllowedRadius, tenant.allowedRadius);
  }

  Future<void> clear() async {
    await _preferences.remove(_keyTenantId);

    await _preferences.remove(_keyTenantName);
    await _preferences.remove(_keyTenantType);
    await _preferences.remove(_keyTenantPhoto);

    await _preferences.remove(_keyTenantLat);
    await _preferences.remove(_keyTenantLng);
    await _preferences.remove(_keyAllowedRadius);
  }
}
