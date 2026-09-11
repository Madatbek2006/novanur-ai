import 'package:nurnova_ai/data/datasource/preference/auth_preferences.dart';
import 'package:dio/dio.dart';

class DynamicTokenInterceptor extends Interceptor {
  final AuthPreferences _authPreferences;

  DynamicTokenInterceptor(this._authPreferences);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    var accessToken = _authPreferences.accessToken;
    if (accessToken.isNotEmpty) {
      final headers = {"Authorization": "Bearer $accessToken"};
      options.headers.addAll(headers);
    }

    handler.next(options);
  }
}
