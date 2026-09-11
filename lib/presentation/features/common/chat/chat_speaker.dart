import 'dart:async';
import 'dart:io';

import 'package:nurnova_ai/data/datasource/preference/speech_rate_preferences.dart';
import 'package:nurnova_ai/data/repositories/speech_rate_repository.dart';
import 'package:nurnova_ai/data/repositories/speech_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Читает вслух ответы ассистента.
///
/// Сначала пробуем движок самого телефона: это мгновенно, офлайн и бесплатно.
/// Но полагаться на него вслепую нельзя — движок может заявлять язык, не имея
/// скачанного голоса, и тогда `speak` молча ничего не произносит. Поэтому
/// перед чтением проверяем голос, а если его нет — просим озвучку у бэкенда.
///
/// Узбекского в движках телефонов нет вовсе, так что он идёт на сервер сразу.
class ChatSpeaker {
  ChatSpeaker(this._speech, this._speechRate) {
    // Экран показывает, что именно читается сейчас, поэтому о завершении
    // нужно узнать со всех сторон: движок мог договорить, его могли
    // отменить или он мог упасть.
    _tts.setCompletionHandler(_finish);
    _tts.setCancelHandler(_finish);
    _tts.setErrorHandler((_) => _finish());
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) _finish();
    });
  }

  /// Вызывается, когда чтение закончилось само или было прервано.
  VoidCallback? onFinished;

  /// Языки, которые телефон в принципе умеет читать, и их коды для движка.
  static const _deviceVoices = {'ru': 'ru-RU', 'en': 'en-US'};

  /// Чем озвучивает сервер. Узбекского нет в движках телефонов, русский нужен
  /// запасным вариантом. Остальное бэкенд отвечает по-английски — значит
  /// и читать это надо по-английски.
  static const _serverLanguages = {'ru': 'ru', 'uz': 'uz'};

  final SpeechRepository _speech;
  final SpeechRateRepository _speechRate;
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();
  final Logger _logger = Logger();

  /// Читаем ли прямо сейчас. Нужен, чтобы обработчики завершения от
  /// прерванного чтения не гасили то, которое только началось: speak()
  /// сначала останавливает предыдущее, и движок на это отвечает отменой.
  bool _speaking = false;

  void _finish() {
    if (!_speaking) return;
    _speaking = false;
    onFinished?.call();
  }

  Future<void> speak(String text, String languageCode) async {
    if (text.trim().isEmpty) return;

    _speaking = false;
    await _silence();

    try {
      final voice = _deviceVoices[languageCode];

      _speaking = true;

      if (voice != null && await _isVoiceUsable(voice)) {
        await _speakOnDevice(text, voice);
        return;
      }

      await _speakFromServer(text, _serverLanguages[languageCode] ?? 'en');
    } catch (error) {
      // Молчащая озвучка не должна ломать сам чат.
      _logger.e("TTS=> не удалось озвучить: $error");
      _finish();
    }
  }

  /// Есть ли на устройстве голос, который отработает без интернета.
  ///
  /// На Android для этого есть `isLanguageInstalled`: он отсеивает голоса,
  /// которым нужна сеть. На iOS такого метода нет, там хватает проверки
  /// доступности — системные голоса идут в комплекте.
  Future<bool> _isVoiceUsable(String voice) async {
    try {
      final usable = Platform.isAndroid
          ? await _tts.isLanguageInstalled(voice)
          : await _tts.isLanguageAvailable(voice);

      if (usable != true) {
        _logger.i("TTS=> голоса $voice на устройстве нет, идём на сервер");
        return false;
      }
      return true;
    } catch (error) {
      _logger.w("TTS=> проверка голоса $voice не удалась ($error), идём на сервер");
      return false;
    }
  }

  Future<void> _speakOnDevice(String text, String voice) async {
    await _tts.setLanguage(voice);
    await _tts.setSpeechRate(_speechRate.getSpeechRate());
    await _tts.speak(text);
  }

  Future<void> _speakFromServer(String text, String languageCode) async {
    final audio = await _speech.synthesize(text: text, lang: languageCode);
    if (audio.isEmpty) return;

    // just_audio читает источник с диска, поэтому кладём WAV во временный файл.
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/chat_speech.wav');
    await file.writeAsBytes(audio, flush: true);

    await _player.setFilePath(file.path);
    // Серверная озвучка идёт готовым файлом, поэтому выбранную скорость
    // применяем к воспроизведению — иначе настройка работала бы только
    // для языков, которые читает сам телефон.
    await _player.setSpeed(
      _speechRate.getSpeechRate() / SpeechRatePreferences.normal,
    );
    // play() ждёт конца воспроизведения, а вызывающему ждать незачем.
    unawaited(_player.play());
  }

  Future<void> stop() async {
    final wasSpeaking = _speaking;
    _speaking = false;
    await _silence();
    if (wasSpeaking) onFinished?.call();
  }

  /// Глушит оба источника, никого не оповещая.
  Future<void> _silence() async {
    await _tts.stop();
    await _player.stop();
  }

  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}
