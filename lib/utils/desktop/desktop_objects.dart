import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:nurnova_ai/core/objects/home_objects.dart';
import 'package:nurnova_ai/utils/desktop/desktop_resources.dart';
import 'package:nurnova_ai/utils/desktop/onnx_runtime.dart';
import 'package:nurnova_ai/utils/web/browser_vision_models.dart';
import 'package:nurnova_ai/utils/web/coco_labels.dart';

/// Предметы на картинке в десктопной версии — то же, что на сайте делает
/// MediaPipe (80 предметов COCO), только нативно: YOLO26n COCO через
/// onnxruntime. Ответ того же вида, что у сайта, поэтому рамки, названия и
/// озвучка общие.
class DesktopObjects {
  static const model = 'models/yolo26n_coco.onnx';

  Future<SendPort>? _worker;

  /// Загрузить модель заранее, чтобы первый ответ пришёл быстрее.
  void preload() => _worker ??= _start();

  Future<VisionObjects> detect(Uint8List encodedImage) async {
    final worker = await (_worker ??= _start());
    final reply = ReceivePort();
    worker.send((TransferableTypedData.fromList([encodedImage]), reply.sendPort));
    final result = await reply.first;
    reply.close();
    if (result is VisionObjects) return result;
    throw StateError('$result');
  }

  Future<SendPort> _start() async {
    final ready = ReceivePort();
    await Isolate.spawn(
      _work,
      (ready.sendPort, desktopResource(model), onnxRuntimeLibrary),
      debugName: 'desktop-objects',
    );
    final reply = await ready.first;
    if (reply is! SendPort) {
      _worker = null; // следующая попытка — заново
      throw StateError('$reply');
    }
    return reply;
  }
}

void _work((SendPort, String, String?) args) {
  final (main, path, library) = args;
  final OnnxSession session;
  try {
    session = OnnxSession.fromBytes(File(path).readAsBytesSync(), library: library);
  } catch (e) {
    main.send('$e');
    return;
  }
  final requests = ReceivePort();
  main.send(requests.sendPort);
  requests.listen((message) {
    final (bytes, reply) = message as (TransferableTypedData, SendPort);
    try {
      reply.send(detectObjects(session, bytes.materialize().asUint8List()));
    } catch (e) {
      reply.send('$e');
    }
  });
}

/// Сторона входа модели и правила отбора — как у сайта: порог 0.45, не
/// больше 15 предметов (`scoreThreshold`, `maxResults` в nurnova_vision.js).
const _side = 640;
const _minScore = 0.45;
const _maxResults = 15;

/// Предметы на закодированной картинке (JPEG, PNG…) — в её пикселях.
VisionObjects detectObjects(OnnxSession session, Uint8List encodedImage) {
  final decoded = img.decodeImage(encodedImage);
  if (decoded == null) throw const FormatException('не картинка');
  final image = img.bakeOrientation(decoded).convert(numChannels: 4);
  final rgba = image.getBytes(order: img.ChannelOrder.rgba);

  final frame = CameraFrame(
    bytes: rgba,
    width: image.width,
    height: image.height,
    bytesPerRow: image.width * 4,
    layout: FrameLayout.rgba8888,
    rotation: 0,
  );
  final letterbox = Letterbox(image.width, image.height, _side);
  final input = Float32List(3 * _side * _side);
  fillInput(frame, letterbox, input);

  final output = session.run(
    input: 'images',
    data: input,
    shape: const [1, 3, _side, _side],
    output: 'output0',
    outputLength: 300 * 6,
  );
  final found = decodeHomeObjects(
    output,
    letterbox,
    minConfidence: _minScore,
    names: CocoLabels.classNames,
  );
  return VisionObjects(
    imageSize: Size(image.width.toDouble(), image.height.toDouble()),
    objects: [
      for (final o in found.take(_maxResults))
        VisionObject(label: o.name, score: o.confidence, box: o.box),
    ],
  );
}
