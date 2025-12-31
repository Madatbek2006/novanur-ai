import 'dart:async';

import 'package:baiqavisit/data/error/app_exception.dart';
import 'package:baiqavisit/data/mappers/dio_error_mappers.dart';
import 'package:logger/logger.dart';

extension StreamExtensions<T> on Stream<T> {
  StreamHandler<T> initFuture() => StreamHandler(this);
}

class StreamHandler<T> {
  final Stream<T> stream;
  StreamSubscription<T>? _subscription;

  Function? _onStart;
  Function(T data)? _onSuccess;
  Function(AppException error)? _onError;
  Function? _onFinished;

  StreamHandler(this.stream);

  StreamHandler<T> onStart(Function callback) {
    _onStart = callback;
    return this;
  }

  StreamHandler<T> onSuccess(Function(T data) callback) {
    _onSuccess = callback;
    return this;
  }

  StreamHandler<T> onError(Function(AppException error) callback) {
    _onError = callback;
    return this;
  }

  StreamHandler<T> onFinished(Function callback) {
    _onFinished = callback;
    return this;
  }

  void executeStream() {
    try {
      _onStart?.call();
      _subscription = stream.listen(
        (data) {
          _onSuccess?.call(data);
        },
        onError: (e, stackTrace) {
          Logger().w("executeStream e = $e, stackTrace = $stackTrace");
          _onError?.call(e.objectToAppException(stackTrace));
        },
        onDone: () {
          _onFinished?.call();
        },
      );
    } catch (e, stackTrace) {
      Logger().w("executeStream e = $e, stackTrace = $stackTrace");
      _onError?.call(e.objectToAppException(stackTrace));
      _onFinished?.call();
    }
  }

  void cancel() {
    _subscription?.cancel();
    _onFinished?.call();
  }
}
