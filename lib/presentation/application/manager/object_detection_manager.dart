import 'dart:io' show Directory, File;

import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ObjectDetectionManager {
  static final ObjectDetectionManager _instance = ObjectDetectionManager._internal();
  factory ObjectDetectionManager() => _instance;

  ObjectDetectionManager._internal();

  ObjectDetector? _detector;
  int _option = 1;

  final _options = {
    'default': 'ssd_mobilenet_v1.tflite',
    'efficientDet-lite': '2.tflite',
    'object_custom': 'object_labeler.tflite',
    'fruits': 'object_labeler_fruits.tflite',
    'flowers': 'object_labeler_flowers.tflite',
    'birds': 'lite-model_aiy_vision_classifier_birds_V1_3.tflite',
    'food': 'lite-model_aiy_vision_classifier_food_V1_1.tflite',
    'plants': 'lite-model_aiy_vision_classifier_plants_V1_3.tflite',
    'mushrooms': 'lite-model_models_mushroom-identification_v1_1.tflite',
    'landmarks':
    'lite-model_on_device_vision_classifier_landmarks_classifier_north_america_V1_1.tflite',
  };

  bool _canProcess = false;

  Future<void> init({
    DetectionMode mode = DetectionMode.single,
    bool classifyObjects = true,
    bool multipleObjects = false,
    int option = 2, // выбор модели
  }) async {
    _option = option;

    _detector?.close();
    _detector = null;

    Logger().d('FFF:Initializing detector with option $_option, mode: $mode');
    // if (_option == 0) {
    //   Logger().d('FFF: Using default model');
    //
    //   // стандартная модель
    //   final optionsObj = ObjectDetectorOptions(
    //     mode: mode,
    //     classifyObjects: classifyObjects,
    //     multipleObjects: multipleObjects,
    //   );
    //   _detector = ObjectDetector(options: optionsObj);
    // } else
      if (_option > 0 && _option < _options.length) {
      // кастомная модель
      final modelName = _options[_options.keys.toList()[_option]] ?? '';
      final modelPath = await getAssetPath('assets/ml/$modelName');
      Logger().d('FFF:Using custom model: $modelPath');

      final optionsObj = LocalObjectDetectorOptions(
        mode: mode,
        modelPath: modelPath,
        classifyObjects: classifyObjects,
        multipleObjects: multipleObjects,
      );
      _detector = ObjectDetector(options: optionsObj);
    }

    _canProcess = true;
  }

  Future<List<DetectedObject>> detect(InputImage image) async {
    if (!_canProcess || _detector == null) {
      throw Exception('ObjectDetectionManager: call init() first.');
    }
    return _detector!.processImage(image);
  }

  Future<void> dispose() async {
    await _detector?.close();
    _detector = null;
    _canProcess = false;
  }

  bool get isInitialized => _detector != null;

  List<String> get modelNames => _options.keys.toList();
}

Future<String> getAssetPath(String asset) async {
  final path = await getLocalPath(asset);
  await Directory(dirname(path)).create(recursive: true);
  final file = File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(asset);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }
  return file.path;
}

Future<String> getLocalPath(String path) async {
  return '${(await getApplicationSupportDirectory()).path}/$path';
}