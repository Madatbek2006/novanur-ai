import 'package:nurnova_ai/data/datasource/preference/token_holder.dart';
import 'package:dio/dio.dart';

class FixedTokenInterceptor extends Interceptor {
  FixedTokenInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    var accessToken = TokenHolder.accessToken;
    if (accessToken.isNotEmpty) {
      final headers = {"Authorization": "Bearer $accessToken"};
      options.headers.addAll(headers);
    }

    handler.next(options);
  }
}
