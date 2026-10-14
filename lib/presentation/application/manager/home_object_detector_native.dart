import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:nurnova_ai/core/objects/home_objects.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Модель «Предметы дома» (yolo26n на HomeObjects-3K) в отдельном потоке.
/// Кадр там же поворачивается, вписывается в квадрат и считается, поэтому
/// интерфейс и превью камеры не подтормаживают.
class HomeObjectDetector {
  static const _asset = 'assets/ml/home_objects.tflite';

  SendPort? _requests;
  Future<void>? _starting;

  bool get isInitialized => _requests != null;

  Future<void> init() => _starting ??= _start();

  Future<void> _start() async {
    final model = await rootBundle.load(_asset);
    final ready = ReceivePort();
    await Isolate.spawn(
      _work,
      (
        ready.sendPort,
        TransferableTypedData.fromList(
          [model.buffer.asUint8List(model.offsetInBytes, model.lengthInBytes)],
        ),
      ),
      debugName: 'home-objects',
    );
    final reply = await ready.first;
    if (reply is! SendPort) {
      _starting = null;
      throw StateError('HomeObjectDetector: $reply');
    }
    _requests = reply;
  }

  /// Пока кадр считается, следующий не шлём: камера сама отбрасывает кадры,
  /// пока идёт разбор предыдущего.
  Future<List<HomeObject>> detect(CameraFrame frame) async {
    final requests = _requests;
    if (requests == null) return const [];
    final reply = ReceivePort();
    requests.send((frame, reply.sendPort));
    final found = await reply.first;
    reply.close();
    return found as List<HomeObject>;
  }

  Future<void> dispose() async {
    _requests?.send(null);
    _requests = null;
    _starting = null;
  }
}

void _work((SendPort, TransferableTypedData) args) {
  final (main, model) = args;

  final Interpreter interpreter;
  try {
    // XNNPACK надо подключать явно: без него TFLite считает простыми ядрами,
    // и кадр, который XNNPACK считает за миллисекунды, занимает почти секунду.
    interpreter = Interpreter.fromBuffer(
      model.materialize().asUint8List(),
      options: InterpreterOptions()
        ..threads = 4
        ..addDelegate(
          XNNPackDelegate(options: XNNPackDelegateOptions(numThreads: 4)),
        ),
    );
  } catch (e) {
    main.send('$e');
    return;
  }

  // Вход [1, 3, side, side]: модель выгружена из PyTorch и ждёт плоскости
  // цветов по отдельности — так его и заполняет fillInput.
  final side = interpreter.getInputTensor(0).shape[2];
  final input = Float32List(side * side * 3);
  final output = Float32List(
    interpreter.getOutputTensor(0).shape.reduce((a, b) => a * b),
  );

  final requests = ReceivePort();
  main.send(requests.sendPort);
  requests.listen((message) {
    if (message == null) {
      requests.close();
      interpreter.close();
      return;
    }
    final (frame, reply) = message as (CameraFrame, SendPort);
    try {
      final letterbox =
          Letterbox(frame.uprightWidth, frame.uprightHeight, side);
      fillInput(frame, letterbox, input);
      interpreter.run(input.buffer.asUint8List(), output.buffer.asUint8List());
      reply.send(decodeHomeObjects(output, letterbox));
    } catch (e) {
      Logger().w('HomeObjectDetector: frame failed: $e');
      reply.send(const <HomeObject>[]);
    }
  });
}
