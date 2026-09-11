import 'dart:async';
import 'dart:io';

import 'package:nurnova_ai/data/repositories/speech_repository.dart';
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
  ChatSpeaker(this._speech);

  /// Языки, которые телефон в принципе умеет читать, и их коды для движка.
  static const _deviceVoices = {'ru': 'ru-RU', 'en': 'en-US'};

  /// Чем озвучивает сервер. Всё, кроме русского и узбекского, бэкенд
  /// отвечает по-английски — значит и читать это надо по-английски.
  static const _serverLanguages = {'ru': 'ru', 'uz': 'uz'};

  final SpeechRepository _speech;
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();
  final Logger _logger = Logger();

  Future<void> speak(String text, String languageCode) async {
    if (text.trim().isEmpty) return;

    await stop();

    try {
      final voice = _deviceVoices[languageCode];

      if (voice != null && await _isVoiceUsable(voice)) {
        await _speakOnDevice(text, voice);
        return;
      }

      await _speakFromServer(text, _serverLanguages[languageCode] ?? 'en');
    } catch (error) {
      // Молчащая озвучка не должна ломать сам чат.
      _logger.e("TTS=> не удалось озвучить: $error");
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
    // play() ждёт конца воспроизведения, а вызывающему ждать незачем.
    unawaited(_player.play());
  }

  Future<void> stop() async {
    await _tts.stop();
    await _player.stop();
  }

  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}
