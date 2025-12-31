import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'dart:math';

class CustomObjectDetector {
  late Interpreter _interpreter;
  late List<String> _labels;
  final int inputSize;

  CustomObjectDetector({this.inputSize = 300});

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/models/ssd_mobilenet_v1.tflite');

    final labelsData = await rootBundle.loadString('assets/models/labelmap.txt');
    _labels = labelsData.split('\n').where((e) => e.isNotEmpty).toList();
  }

  /// Конвертируем RGB Uint8List в TensorInput
  Float32List _preprocess(Uint8List rgbBytes) {
    final input = Float32List(inputSize * inputSize * 3);
    for (int i = 0; i < rgbBytes.length; i++) {
      input[i] = rgbBytes[i] / 255.0; // нормализация 0..1
    }
    return input;
  }

  Future<List<DetectedObjectResult>> predict(Uint8List rgbBytes) async {
    final inputTensor = _preprocess(rgbBytes).reshape([1, inputSize, inputSize, 3]);

    // выходные массивы (пример для модели SSD MobileNet)
    var outputLocations = List.filled(1 * 10 * 4, 0.0).reshape([1, 10, 4]);
    var outputClasses = List.filled(1 * 10, 0.0).reshape([1, 10]);
    var outputScores = List.filled(1 * 10, 0.0).reshape([1, 10]);
    var numDetections = List.filled(1, 0.0);

    final outputs = {
      0: outputLocations,
      1: outputClasses,
      2: outputScores,
      3: numDetections,
    };

    _interpreter.runForMultipleInputs([inputTensor], outputs);

    final results = <DetectedObjectResult>[];
    int n = numDetections[0].toInt();

    for (int i = 0; i < n; i++) {
      final score = outputScores[0][i];
      if (score < 0.5) continue;

      final labelIndex = outputClasses[0][i].toInt();
      final label = _labels[labelIndex];

      final box = outputLocations[0][i]; // [ymin, xmin, ymax, xmax]
      results.add(DetectedObjectResult(
        label: label,
        confidence: score,
        rect: Rect.fromLTWH(box[1], box[0], box[3] - box[1], box[2] - box[0]),
      ));
    }

    return results;
  }
}

class DetectedObjectResult {
  final String label;
  final double confidence;
  final Rect rect;

  DetectedObjectResult({required this.label, required this.confidence, required this.rect});
}

extension Float32ListReshape on Float32List {
  List reshape(List<int> dims) {
    // Заглушка: TFLite Flutter требует List, здесь оставляем как Float32List
    return [this];
  }
}
