import 'dart:math' as math;
import 'dart:typed_data';

/// Огибающая звука для столбиков плеера.
///
/// Разбирает WAV, который отдаёт бэкенд: PCM, 16 бит, моно. Заголовок читается
/// честно, по чанкам, а не по фиксированным 44 байтам — у разных кодировщиков
/// перед `data` бывают лишние чанки.
///
/// Возвращает [bars] значений 0..1. Если формат не тот или данных нет, вернёт
/// пустой список: экран в этом случае рисует простую полосу вместо столбиков.
List<double> peaksFromWav(Uint8List bytes, {int bars = 48}) {
  if (bars <= 0) return const <double>[];

  final samples = _readPcm16Mono(bytes);
  if (samples == null || samples.isEmpty) return const <double>[];

  final perBar = samples.length / bars;
  if (perBar < 1) return const <double>[];

  final peaks = List<double>.filled(bars, 0);
  var loudest = 0.0;

  for (var bar = 0; bar < bars; bar++) {
    final start = (bar * perBar).floor();
    final end = math.min(((bar + 1) * perBar).floor(), samples.length);

    // Среднеквадратичное, а не пик: одиночный щелчок не должен превращаться
    // в столбик во всю высоту рядом с ровной речью.
    var sum = 0.0;
    for (var i = start; i < end; i++) {
      final value = samples[i] / 32768.0;
      sum += value * value;
    }

    final rms = end > start ? math.sqrt(sum / (end - start)) : 0.0;
    peaks[bar] = rms;
    if (rms > loudest) loudest = rms;
  }

  if (loudest <= 0) return const <double>[];

  // Нормируем по самому громкому месту, иначе тихая запись даёт плоскую линию.
  for (var i = 0; i < bars; i++) {
    peaks[i] = (peaks[i] / loudest).clamp(0.0, 1.0);
  }
  return peaks;
}

/// Достаёт сэмплы из WAV, если он PCM 16 бит моно. Иначе — null.
Int16List? _readPcm16Mono(Uint8List bytes) {
  // 12 байт на "RIFF" + размер + "WAVE", дальше идут чанки.
  if (bytes.length < 44) return null;

  final data = ByteData.sublistView(bytes);
  if (_tag(bytes, 0) != 'RIFF' || _tag(bytes, 8) != 'WAVE') return null;

  var channels = 0;
  var bitsPerSample = 0;
  var offset = 12;

  while (offset + 8 <= bytes.length) {
    final id = _tag(bytes, offset);
    final size = data.getUint32(offset + 4, Endian.little);
    final body = offset + 8;

    if (id == 'fmt ' && body + 16 <= bytes.length) {
      final format = data.getUint16(body, Endian.little);
      channels = data.getUint16(body + 2, Endian.little);
      bitsPerSample = data.getUint16(body + 14, Endian.little);
      // 1 — несжатый PCM. Всё остальное разбирать не берёмся.
      if (format != 1) return null;
    } else if (id == 'data') {
      if (channels != 1 || bitsPerSample != 16) return null;

      final end = math.min(body + size, bytes.length);
      final count = (end - body) ~/ 2;
      if (count <= 0) return null;

      final samples = Int16List(count);
      for (var i = 0; i < count; i++) {
        samples[i] = data.getInt16(body + i * 2, Endian.little);
      }
      return samples;
    }

    // Чанки выравниваются по чётной границе.
    offset = body + size + (size.isOdd ? 1 : 0);
  }

  return null;
}

String _tag(Uint8List bytes, int offset) {
  if (offset + 4 > bytes.length) return '';
  return String.fromCharCodes(bytes, offset, offset + 4);
}
