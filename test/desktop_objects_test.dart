import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nurnova_ai/utils/desktop/desktop_objects.dart';
import 'package:nurnova_ai/utils/desktop/onnx_runtime.dart';

/// Настоящий прогон YOLO через onnxruntime. Нужна библиотека onnxruntime
/// (ORT_LIB: на Windows — onnxruntime.dll из sherpa_onnx_windows, на маке —
/// из pip onnxruntime), фото (OBJECTS_PHOTO) и что на нём должно найтись
/// (OBJECTS_EXPECT). Без них проверка пропускается.
void main() {
  final library = Platform.environment['ORT_LIB'] ?? '';
  final photo = Platform.environment['OBJECTS_PHOTO'] ?? '';
  final ready = File(library).existsSync() && File(photo).existsSync();

  test('находит предметы на фото комнаты, рамки внутри картинки', () {
    final session = OnnxSession.fromBytes(
      File('desktop/models/yolo26n_coco.onnx').readAsBytesSync(),
      library: library,
    );
    final found = detectObjects(session, File(photo).readAsBytesSync());
    session.close();

    final labels = found.objects.map((o) => o.label).toList();
    // ignore: avoid_print
    print('${found.imageSize}: ${found.objects.map((o) => '${o.label} ${o.score.toStringAsFixed(2)}').join(', ')}');
    expect(labels, contains(Platform.environment['OBJECTS_EXPECT'] ?? 'potted plant'));
    expect(found.objects.length, lessThanOrEqualTo(15));
    for (final o in found.objects) {
      expect(o.score, greaterThanOrEqualTo(0.45));
      expect(o.box.left, greaterThanOrEqualTo(0));
      expect(o.box.right, lessThanOrEqualTo(found.imageSize.width));
      expect(o.box.bottom, lessThanOrEqualTo(found.imageSize.height));
    }
  }, skip: ready ? false : 'нет ORT_LIB / OBJECTS_PHOTO');
}
