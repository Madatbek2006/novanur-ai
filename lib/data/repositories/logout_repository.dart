import 'dart:async';

import 'package:nurnova_ai/data/datasource/floor/dao/tenant_entity_dao.dart';
import 'package:nurnova_ai/data/datasource/floor/dao/user_entity_dao.dart';
import 'package:nurnova_ai/data/datasource/preference/auth_preferences.dart';
import 'package:nurnova_ai/data/datasource/preference/fcm_token_preferences.dart';
import 'package:nurnova_ai/data/datasource/preference/pin_code_preferences.dart';
import 'package:nurnova_ai/data/datasource/preference/tenant_preferences.dart';
import 'package:nurnova_ai/data/datasource/preference/user_preferences.dart';

class LogoutRepository {
  final AuthPreferences _authPreferences;
  final FcmTokenPreferences _fcmTokenPreferences;
  final PinCodePreferences _pinCodePreferences;
  final TenantEntityDao _tenantEntityDao;
  final TenantPreferences _tenantPreferences;
  final UserEntityDao _userEntityDao;
  final UserPreferences _userPreferences;

  LogoutRepository(
    this._authPreferences,
    this._fcmTokenPreferences,
    this._pinCodePreferences,
    this._tenantEntityDao,
    this._tenantPreferences,
    this._userEntityDao,
    this._userPreferences,
  );

  Future<void> clearBeforeLogout() async {
    await _authPreferences.clear();
    await _fcmTokenPreferences.clear();
    await _pinCodePreferences.clear();
    await _tenantEntityDao.clear();
    await _tenantPreferences.clear();
    await _userEntityDao.clear();
    await _userPreferences.clear();
    return;
  }
}
