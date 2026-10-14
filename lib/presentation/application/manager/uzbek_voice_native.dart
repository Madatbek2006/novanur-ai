import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:nurnova_ai/core/audio/wav_encoder.dart';
import 'package:nurnova_ai/core/speech/uzbek_text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Узбекский голос прямо на телефоне — без сети и без бэка.
///
/// Та же модель, что синтезирует сервер (MMS, facebook/mms-tts-uzb-script_
/// cyrillic), выгруженная для sherpa-onnx и сжатая до 22 МБ без потери звука
/// — см. tool/tts/export_mms_uz.py. Синтез тяжёлый и синхронный, поэтому
/// идёт в отдельном потоке; модель грузится один раз на всё приложение.
class UzbekVoice {
  static const _model = 'assets/tts/uz/model.onnx';
  static const _tokens = 'assets/tts/uz/tokens.txt';

  /// Меняется вместе с моделью: под новым именем файл скопируется заново.
  static const _version = 'mms-uz-mixed-1';

  /// Пауза между кусками — как у сервера (`PAUSE_SECONDS`).
  static const _gap = Duration(milliseconds: 80);

  Future<_Engine?>? _engine;

  /// WAV (PCM, 16 бит, моно) — или null, если голос на телефоне не
  /// поднялся: тогда узбекский, как раньше, озвучит сервер. Пустой список
  /// байтов — в тексте нечего произносить.
  Future<Uint8List?> synthesize(String text) async {
    final engine = await (_engine ??= _start());
    if (engine == null) return null;

    final chunks = uzbekSpeechChunks(text, engine.alphabet);
    if (chunks.isEmpty) return Uint8List(0);

    final reply = ReceivePort();
    engine.requests.send((chunks, reply.sendPort));
    final result = await reply.first;
    reply.close();

    if (result is TransferableTypedData) {
      return result.materialize().asUint8List();
    }
    Logger().w('UzbekVoice: синтез не удался ($result), идём на сервер');
    return null;
  }

  Future<_Engine?> _start() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final model = await _copy(_model, '${dir.path}/$_version.onnx');
      final tokens = await _copy(_tokens, '${dir.path}/$_version.tokens.txt');
      final alphabet = {
        for (final line in await File(tokens).readAsLines())
          if (line.isNotEmpty) line.substring(0, line.lastIndexOf(' ')),
      }..remove('|'); // служебный пустой токен, не буква

      final ready = ReceivePort();
      await Isolate.spawn(_work, (ready.sendPort, model, tokens),
          debugName: 'uzbek-voice');
      final reply = await ready.first;
      if (reply is! SendPort) throw StateError('$reply');
      return _Engine(reply, alphabet);
    } catch (e) {
      Logger().w('UzbekVoice: голос на телефоне недоступен ($e), '
          'узбекский пойдёт с сервера');
      return null;
    }
  }

  /// sherpa-onnx читает модель по пути, а ресурс лежит внутри APK —
  /// копируем один раз на диск.
  static Future<String> _copy(String asset, String path) async {
    final file = File(path);
    if (!await file.exists()) {
      final data = await rootBundle.load(asset);
      final tmp = File('$path.part');
      await tmp.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
      await tmp.rename(path); // недописанный файл не должен выглядеть готовым
    }
    return path;
  }
}

class _Engine {
  _Engine(this.requests, this.alphabet);

  final SendPort requests;

  /// Знаки, которые модель умеет произносить.
  final Set<String> alphabet;
}

void _work((SendPort, String, String) args) {
  final (main, model, tokens) = args;

  final sherpa.OfflineTts tts;
  try {
    sherpa.initBindings();
    tts = sherpa.OfflineTts(
      sherpa.OfflineTtsConfig(
        model: sherpa.OfflineTtsModelConfig(
          vits: sherpa.OfflineTtsVitsModelConfig(model: model, tokens: tokens),
          numThreads: 4,
          debug: false,
        ),
      ),
    );
  } catch (e) {
    main.send('$e');
    return;
  }

  final requests = ReceivePort();
  main.send(requests.sendPort);
  requests.listen((message) {
    final (chunks, reply) = message as (List<String>, SendPort);
    try {
      final pieces = <Float32List>[];
      var rate = 16000;
      for (final chunk in chunks) {
        final audio = tts.generate(text: chunk);
        rate = audio.sampleRate;
        pieces.add(audio.samples);
      }
      final wav = encodeWav(pieces, rate, gap: UzbekVoice._gap);
      reply.send(TransferableTypedData.fromList([wav]));
    } catch (e) {
      reply.send('$e');
    }
  });
}
