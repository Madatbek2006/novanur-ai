import 'package:baiqavisit/data/datasource/network/dto/default/default_error_response.dart';
import 'package:baiqavisit/data/mappers/dio_error_mappers.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@lazySingleton
class ErrorInterceptor extends InterceptorsWrapper {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final statusCode = response.statusCode;
    if (statusCode == null || (statusCode < 200 && statusCode > 299)) {
      DefaultErrorResponse? error;
      try {
        final data = response.data;
        if (data is Map<String, dynamic> && data['detail'] != null) {
          error = DefaultErrorResponse(detailMessage: data['detail']);
        } else {
          error = DefaultErrorResponse.fromJson(data);
        }
      } catch (e) {
        Logger().w("onResponse Error parsing default error response => $e");
      }
      final exception = response.dioResponseToAppException(error?.detailMessage);
      Logger().w("onResponse s = $statusCode, r = $response, e = $exception");

      throw exception;
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String? detailMessage;

    if (err.response?.data != null) {
      try {
        final data = err.response!.data;
        if (data is Map<String, dynamic> && data['detail'] != null) {
          detailMessage = data['detail'] as String?;
        } else {
          detailMessage = DefaultErrorResponse.fromJson(data).detailMessage;
        }
      } catch (e) {
        Logger().w("onError error parsing default error response => $e");
      }
    }

    final exception = err.dioExceptionToAppException(detailMessage);
    Logger().w("onError => dio e = $err app e = $exception");
    throw exception;
  }
}
