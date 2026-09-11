import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeechRatePreferences {
  final SharedPreferences _preferences;

  SpeechRatePreferences(this._preferences);

  static const String _keySpeechRate = "double_speech_rate";

  /// Шкала flutter_tts: плагин приводит платформы к общему виду, и 0.5 у него
  /// означает обычную скорость речи, а 1.0 — вдвое быстрее.
  static const double normal = 0.5;
  static const double min = 0.25;
  static const double max = 1.0;

  double get speechRate =>
      _preferences.getDouble(_keySpeechRate)?.clamp(min, max) ?? normal;

  @factoryMethod
  static Future<SpeechRatePreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SpeechRatePreferences(prefs);
  }

  Future<void> setSpeechRate(double rate) async =>
      await _preferences.setDouble(_keySpeechRate, rate.clamp(min, max));

  Future<void> clear() async => await _preferences.remove(_keySpeechRate);
}
