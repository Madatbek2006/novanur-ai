import 'dart:async';

import 'package:logger/logger.dart';

class BaseStreamController<T> {
  final StreamController<T> _controller;

  BaseStreamController({
    bool sync = false,
    bool isBroadcast = false,
  }) : _controller = isBroadcast
            ? StreamController<T>.broadcast(sync: sync)
            : StreamController<T>(sync: sync);

  Stream<T> get stream => _controller.stream;

  void add(T data) {
    _controller.add(data);
  }

  Future<void> addAndClose(T data) async {
    _controller.add(data);
    await _controller.close();
  }

  void addError(Object error, [StackTrace? stackTrace]) {
    _controller.addError(error, stackTrace);
  }

  Future<void> close() {
    return _controller.close();
  }

  bool get isClosed => _controller.isClosed;

  bool get hasListener => _controller.hasListener;

  StreamSink<T> get sink => _controller.sink;

  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _controller.stream.listen(
      onData,
      onError: onError ??
          (error, stackTrace) {
            Logger().e("Stream error: $error, stackTrace: $stackTrace");
          },
      onDone: onDone ??
          () {
            Logger().i("Stream has been closed.");
          },
      cancelOnError: cancelOnError ?? true,
    );
  }
}
