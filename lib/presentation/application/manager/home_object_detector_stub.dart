import 'package:nurnova_ai/core/objects/home_objects.dart';

/// Заглушка для сайта: модель «Предметы дома» там не запускается.
class HomeObjectDetector {
  bool get isInitialized => false;

  Future<void> init() async {}

  Future<List<HomeObject>> detect(CameraFrame frame) async => const [];

  Future<void> dispose() async {}
}
