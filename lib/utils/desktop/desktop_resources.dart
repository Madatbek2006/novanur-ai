import 'dart:io';

/// Путь к файлу, который едет только с десктопной сборкой: модели и словари
/// распознавания. В ресурсах Flutter их нет нарочно — иначе они попали бы и в
/// APK телефона.
///
/// На Windows CMake кладёт папку `desktop/` в `data/desktop` рядом с
/// программой (см. windows/CMakeLists.txt). Для запуска на маке путь
/// задаётся явно: `--dart-define=NURNOVA_DESKTOP_DATA=<mobile/desktop>`.
String desktopResource(String name) {
  const override = String.fromEnvironment('NURNOVA_DESKTOP_DATA');
  final dir = override.isNotEmpty
      ? override
      : '${File(Platform.resolvedExecutable).parent.path}/data/desktop';
  return '$dir/$name';
}

/// onnxruntime — на Windows тот, что рядом с программой (его везёт
/// sherpa-onnx). На маке sherpa-onnx вшивает его в себя, и для проверок путь
/// к отдельной библиотеке задаётся `--dart-define=NURNOVA_ONNXRUNTIME=...`.
String? get onnxRuntimeLibrary {
  const override = String.fromEnvironment('NURNOVA_ONNXRUNTIME');
  return override.isNotEmpty ? override : null;
}
