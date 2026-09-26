import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:nurnova_ai/core/audio/wav_peaks.dart';
import 'package:nurnova_ai/data/datasource/preference/speech_rate_preferences.dart';
import 'package:nurnova_ai/data/repositories/speech_rate_repository.dart';
import 'package:nurnova_ai/data/repositories/speech_repository.dart';
import 'package:nurnova_ai/domain/models/chat/speech_playback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Читает вслух ответы ассистента и управляет их воспроизведением.
///
/// Звук приходит двумя разными путями, и это определяет, что можно показать
/// на экране. Русский и английский читает движок телефона — мгновенно, офлайн
/// и бесплатно, но он говорит прямо в динамик: файла нет, а значит нет ни
/// длительности, ни позиции, ни перемотки. Узбекский синтезирует бэкенд и
/// присылает WAV — вот у него есть всё, включая огибающую для столбиков.
///
/// Полагаться на движок вслепую нельзя: он может заявлять язык, не имея
/// скачанного голоса, и тогда `speak` молча ничего не произносит. Поэтому
/// голос проверяется, а при его отсутствии озвучку берём с сервера.
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

  /// Состояние озвучки изменилось. null означает тишину.
  void Function(SpeechPlayback? playback)? onPlayback;

  /// Позиция воспроизведения. Идёт отдельным потоком мимо состояния чата:
  /// она тикает десятки раз в секунду, а состояние сравнивается целиком,
  /// так что каждый тик перерисовывал бы весь список сообщений.
  Stream<Duration> get positionStream => _player.positionStream;

  /// Языки, которые телефон в принципе умеет читать, и их коды для движка.
  static const _deviceVoices = {'ru': 'ru-RU', 'en': 'en-US'};

  /// Чем озвучивает сервер. Узбекского нет в движках телефонов, русский нужен
  /// запасным вариантом. Остальное бэкенд отвечает по-английски — значит
  /// и читать это надо по-английски.
  static const _serverLanguages = {'ru': 'ru', 'uz': 'uz'};

  /// Сколько столбиков рисуем. Больше в ширину пузыря всё равно не влезает.
  static const _waveformBars = 48;

  final SpeechRepository _speech;
  final SpeechRateRepository _speechRate;
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();
  final Logger _logger = Logger();

  /// Огибающие уже озвученных сообщений: повторное прослушивание не должно
  /// заново считать их из файла.
  final Map<String, List<double>> _peaks = {};

  /// Файлы, синтезированные за этот сеанс, — чтобы подчистить за собой.
  final Set<String> _files = {};

  /// Готовые озвучки: всё, что известно о звуке каждого сообщения.
  /// Экран берёт отсюда полосу для ответов, которые сейчас не звучат.
  final Map<String, SpeechPlayback> _clips = {};

  /// Что известно об озвучке каждого сообщения — для полос, которые молчат.
  Map<String, SpeechPlayback> get clips => Map.unmodifiable(_clips);

  SpeechPlayback? _playback;

  /// Читаем ли прямо сейчас. Нужен, чтобы обработчики завершения от
  /// прерванного чтения не гасили то, которое только началось: speak()
  /// сначала останавливает предыдущее, и движок на это отвечает отменой.
  bool _speaking = false;

  void _emit(SpeechPlayback? playback) {
    _playback = playback;
    onPlayback?.call(playback);
  }

  void _finish() {
    if (!_speaking) return;
    _speaking = false;
    _emit(_rested(_playback));
  }

  /// Переводит озвучку в молчаливое состояние, сохраняя полосу.
  ///
  /// У движка телефона сохранять нечего: файла нет, перематывать нечего,
  /// поэтому для него по-прежнему возвращается тишина и остаётся одна
  /// кнопка — это честнее, чем рисовать мёртвую полосу.
  SpeechPlayback? _rested(SpeechPlayback? playback) {
    if (playback == null || !playback.seekable) return null;

    // Позицию плеера здесь не трогаем: полоса в покое её и не показывает,
    // а повторное прослушивание всё равно заново открывает файл.
    final clip = playback.copyWith(status: SpeechStatus.idle);
    _clips[playback.messageId] = clip;
    return clip;
  }

  /// Проговаривает служебный текст — например, сообщение об ошибке.
  ///
  /// Плеер для него не появляется: это не ответ ассистента, переслушивать
  /// и перематывать там нечего.
  Future<void> announce(String text, String languageCode) =>
      speak(null, text, languageCode);

  /// Начинает читать сообщение заново — с начала.
  /// [messageId] равен null для служебных объявлений, у которых нет пузыря.
  Future<void> speak(String? messageId, String text, String languageCode) async {
    if (text.trim().isEmpty) return;

    _speaking = false;
    await _silence();

    try {
      final voice = _deviceVoices[languageCode];

      _speaking = true;

      if (voice != null && await _isVoiceUsable(voice)) {
        await _speakOnDevice(messageId, text, voice);
        return;
      }

      await _speakFromServer(
        messageId,
        text,
        _serverLanguages[languageCode] ?? 'en',
      );
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

  Future<void> _speakOnDevice(String? messageId, String text, String voice) async {
    // У движка нет ни файла, ни длительности — перематывать нечего,
    // поэтому экран покажет для него одну кнопку без полосы.
    if (messageId != null) {
      _emit(SpeechPlayback(
        messageId: messageId,
        status: SpeechStatus.playing,
      ));
    }

    await _tts.setLanguage(voice);
    await _tts.setSpeechRate(_speechRate.getSpeechRate());
    await _tts.speak(text);
  }

  Future<void> _speakFromServer(
    String? messageId,
    String text,
    String languageCode,
  ) async {
    // Служебное объявление не кэшируем: оно одноразовое.
    final cached = messageId == null ? null : await _cachedFile(messageId);

    if (cached == null && messageId != null) {
      // Синтез занимает заметное время, и пользователь должен видеть, что
      // происходит, а не гадать, почему тишина.
      _emit(SpeechPlayback(
        messageId: messageId,
        status: SpeechStatus.loading,
        seekable: true,
      ));
    }

    final file =
        cached ?? await _synthesizeToFile(messageId, text, languageCode);
    if (file == null) {
      // Выйти молча нельзя: без этого состояние залипнет на «читается»,
      // и пузырь навсегда останется с кнопкой «стоп».
      _finish();
      return;
    }

    final duration = await _player.setFilePath(file.path);

    // Серверная озвучка идёт готовым файлом, поэтому выбранную скорость
    // применяем к воспроизведению — иначе настройка работала бы только
    // для языков, которые читает сам телефон.
    await _player.setSpeed(
      _speechRate.getSpeechRate() / SpeechRatePreferences.normal,
    );

    if (!_speaking) return;

    if (messageId != null) {
      final playing = SpeechPlayback(
        messageId: messageId,
        status: SpeechStatus.playing,
        seekable: true,
        duration: duration ?? Duration.zero,
        peaks: _peaks[messageId] ?? const <double>[],
      );

      // Запоминаем сразу, а не по окончании: пользователь может переключиться
      // на другой ответ, не дослушав, и тогда конца воспроизведения не будет
      // вовсе — а полоса у этого сообщения остаться обязана.
      _clips[messageId] = playing.copyWith(status: SpeechStatus.idle);
      _emit(playing);
    }

    // play() ждёт конца воспроизведения, а вызывающему ждать незачем.
    unawaited(_player.play());
  }

  /// Уже синтезированный файл этого сообщения, если он есть: повторное
  /// прослушивание не должно снова ходить в сеть.
  Future<File?> _cachedFile(String messageId) async {
    final file = File(await _pathFor(messageId));
    return await file.exists() ? file : null;
  }

  Future<File?> _synthesizeToFile(
    String? messageId,
    String text,
    String languageCode,
  ) async {
    final Uint8List audio =
        await _speech.synthesize(text: text, lang: languageCode);
    if (audio.isEmpty) return null;

    final file = File(await _pathFor(messageId ?? 'announcement'));
    await file.writeAsBytes(audio, flush: true);
    _files.add(file.path);

    // Считаем огибающую один раз, при получении: на повторе она берётся
    // из кэша, а на чужих форматах вернётся пустой список, и полоса
    // нарисуется без столбиков.
    if (messageId != null) {
      _peaks[messageId] = peaksFromWav(audio, bars: _waveformBars);
    }

    return file;
  }

  Future<String> _pathFor(String messageId) async {
    final directory = await getTemporaryDirectory();
    // Файл на сообщение, а не один общий: иначе новый ответ затирает
    // предыдущий и переслушать его уже нельзя.
    return '${directory.path}/chat_speech_$messageId.wav';
  }

  Future<void> pause() async {
    if (_playback?.status != SpeechStatus.playing || !_playback!.seekable) {
      return;
    }
    await _player.pause();
    _emit(_playback!.copyWith(status: SpeechStatus.paused));
  }

  Future<void> resume() async {
    if (_playback?.status != SpeechStatus.paused) return;
    _emit(_playback!.copyWith(status: SpeechStatus.playing));
    unawaited(_player.play());
  }


  Future<void> seek(Duration position) async {
    if (_playback?.seekable != true) return;
    await _player.seek(position);
  }

  Future<void> stop() async {
    final wasSpeaking = _speaking;
    _speaking = false;
    await _silence();
    if (wasSpeaking) _emit(_rested(_playback));
  }

  /// Глушит оба источника, никого не оповещая.
  Future<void> _silence() async {
    await _tts.stop();
    await _player.stop();
  }

  Future<void> dispose() async {
    await stop();
    await _player.dispose();

    // Временные файлы сеанса за собой убираем: их размер — сотни килобайт
    // на сообщение, а пережить сеанс им незачем.
    for (final path in _files) {
      try {
        await File(path).delete();
      } catch (_) {
        // Файл мог исчезнуть сам — системе виднее.
      }
    }
    _files.clear();
    _peaks.clear();
    _clips.clear();
  }
}
