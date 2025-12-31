import 'package:baiqavisit/data/datasource/network/dto/auth/token/refresh_token_request.dart';
import 'package:baiqavisit/data/datasource/preference/auth_preferences.dart';
import 'package:baiqavisit/domain/models/logout/logout_event.dart';
import 'package:baiqavisit/domain/stream_controllers/logout_event_stream_controller.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class RefreshTokenInterceptor extends Interceptor {
  final AuthPreferences _authPreferences;
  final Dio _dio;
  final LogoutEventStreamController _logoutEventStreamController;

  RefreshTokenInterceptor(
    this._authPreferences,
    this._dio,
    this._logoutEventStreamController,
  );

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response == null) handler.next(err);

    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode == 401) {
      Logger().e("RefreshToken onError access token expired");

      try {
        final retryResponse = await _retrySendRequest(
          err.requestOptions,
          err.response,
        );

        if (retryResponse != null && retryResponse.statusCode == 200) {
          handler.resolve(retryResponse);
        } else {
          handler.next(err);
        }
        return;
      } on DioError catch (e) {
        Logger().e("RefreshToken onError retry error = $e");
        handler.next(e);
        return;
      }
    }

    return handler.next(err);
  }

  Future<bool> _refreshToken() async {
    var refreshToken = _authPreferences.refreshToken;
    if (refreshToken.isEmpty) {
      Logger().e("RefreshToken refreshing will skipped refreshToken not exist");
      return false;
    }

    try {
      final response = await _dio.post(
        '/mobile/token/refresh/',
        data: RefreshTokenRequest(refreshToken: _authPreferences.refreshToken),
      );
      Logger().e("RefreshToken refreshing response = $response");
      if (response.statusCode == 200) {
        // final refreshResponse = RefreshTokenResponse.fromJson(response.data);
        // final accessToken = refreshResponse.accessToken;
        // final refreshToken = refreshResponse.refreshToken;
        final accessToken = response.data['access'];
        final refreshToken = response.data['refresh'];
        Logger()
            .w("RefreshToken access = $accessToken, refresh = $refreshToken");
        _authPreferences.setAccessToken(accessToken);
        _authPreferences.setRefreshToken(refreshToken);

        return true;
      }
      return false;
    } catch (e) {
      Logger().e("RefreshToken error = $e");
      return false;
    }
  }

  Future<Response?> _retrySendRequest(
    RequestOptions requestOptions,
    Response? failedResponse,
  ) async {
    try {
      final isRefreshed = await _refreshToken();
      if (isRefreshed) {
        var accessToken = _authPreferences.accessToken;
        requestOptions.headers["Authorization"] = "Bearer $accessToken";

        final retryResponse = await _dio.request(
          requestOptions.path,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
        );

        Logger().e("RefreshToken retrySendRequest = $retryResponse");

        return retryResponse;
      } else {
        Logger().e("RefreshToken retrySendRequest failed => data will cleared");
        _logoutEventStreamController.add(LogoutEvent.onTokenExpired);

        return failedResponse;
      }
    } catch (e) {
      Logger().e("RefreshToken retrySendRequest error = $e");
      return failedResponse;
    }
  }
}
