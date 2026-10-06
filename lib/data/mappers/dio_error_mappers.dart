import 'dart:io';

import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/data/error/app_exception.dart';
import 'package:nurnova_ai/data/error/app_network_exception.dart';
import 'package:dio/dio.dart';

extension DioErrorExts on DioError {
  AppNetworkException dioErrorToAppException() {
    if (error is SocketException) {
      return AppNetworkConnectionException(
        message: Strings.messageConnectionError,
        statusCode: -499,
      );
    }

    if (error is AppNetworkException) {
      return error as AppNetworkException;
    }

    if (response != null) {
      return AppNetworkHttpException(
        message: response?.statusMessage ?? message,
        statusCode: response?.statusCode ?? -488,
      );
    }

    return AppNetworkDioException(
      message: message,
      statusCode: -477,
    );
  }
}

extension DioExceptionExts on DioException {
  AppNetworkException dioExceptionToAppException(String? detailErrorMessage) {
    if (error is AppNetworkException) {
      return error as AppNetworkException;
    }

    return response != null
        ? AppNetworkDioException(
            message: detailErrorMessage ?? response?.statusMessage ?? message,
            statusCode: response?.statusCode ?? -466,
          )
        : AppNetworkConnectionException(
            message: message,
            statusCode: -455,
          );
  }
}

extension DioResponseExceptionExts on Response {
  AppNetworkException dioResponseToAppException(String? detailErrorMessage) {
    return AppNetworkHttpException(
      message: detailErrorMessage ?? statusMessage,
      statusCode: statusCode ?? -444,
    );
  }
}

extension ObjectExceptionExts on Object {
  AppException objectToAppException(StackTrace? stackTrace) {
    if (this is AppException) {
      return this as AppException;
    }
    if (this is DioError) {
      return (this as DioError).dioErrorToAppException();
    }
    if (this is DioException) {
      return (this as DioException).dioExceptionToAppException((this as DioException).response.toString());
    }

    return AppNetworkDioException(message: null, statusCode: 1);
  }
}
