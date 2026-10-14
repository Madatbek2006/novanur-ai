import 'dart:typed_data';

/// Склеивает куски речи в WAV — PCM, 16 бит, моно, как отдаёт бэкенд, — с
/// тишиной [gap] между кусками. Тот же формат, что у сервера, поэтому плеер,
/// огибающая (`peaksFromWav`) и кэш работают с ним одинаково.
Uint8List encodeWav(
  List<Float32List> pieces,
  int sampleRate, {
  Duration gap = Duration.zero,
}) {
  final gapSamples = (sampleRate * gap.inMicroseconds / 1e6).round();
  var total = 0;
  for (var i = 0; i < pieces.length; i++) {
    total += pieces[i].length + (i > 0 ? gapSamples : 0);
  }

  final bytes = ByteData(44 + total * 2);
  void ascii(int at, String text) {
    for (var i = 0; i < text.length; i++) {
      bytes.setUint8(at + i, text.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  bytes.setUint32(4, 36 + total * 2, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  bytes
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little) // PCM
    ..setUint16(22, 1, Endian.little) // моно
    ..setUint32(24, sampleRate, Endian.little)
    ..setUint32(28, sampleRate * 2, Endian.little)
    ..setUint16(32, 2, Endian.little)
    ..setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  bytes.setUint32(40, total * 2, Endian.little);

  var at = 44;
  for (var i = 0; i < pieces.length; i++) {
    if (i > 0) at += gapSamples * 2; // тишина — уже нули
    for (final sample in pieces[i]) {
      bytes.setInt16(at, (sample.clamp(-1.0, 1.0) * 32767).round(), Endian.little);
      at += 2;
    }
  }
  return bytes.buffer.asUint8List();
}
