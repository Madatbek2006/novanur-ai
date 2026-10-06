import 'package:nurnova_ai/data/datasource/preference/speech_rate_preferences.dart';

class SpeechRateRepository {
  final SpeechRatePreferences _speechRatePreferences;

  SpeechRateRepository(this._speechRatePreferences);

  double getSpeechRate() => _speechRatePreferences.speechRate;

  Future<void> setSpeechRate(double rate) =>
      _speechRatePreferences.setSpeechRate(rate);
}
