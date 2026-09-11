import 'package:nurnova_ai/data/error/app_exception.dart';

abstract class AppNetworkException extends AppException {
  @override
  bool get isRequiredShowError => false;
}

class AppNetworkConnectionException extends AppNetworkException {
  final String? message;
  final int statusCode;

  AppNetworkConnectionException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() {
    return "AppNetworkConnectionException: $message (Status code: $statusCode)";
  }
}

class AppNetworkDioException extends AppNetworkException {
  final String? message;
  final int statusCode;

  AppNetworkDioException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() {
    return "AppNetworkDioException: $message (Status code: $statusCode)";
  }

  @override
  bool get isRequiredShowError => false;
}

class AppNetworkHttpException extends AppNetworkException {
  final String? message;
  final int statusCode;

  AppNetworkHttpException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() {
    return "AppNetworkHttpException: $message (Status code: $statusCode)";
  }

  @override
  bool get isRequiredShowError => false;
}
