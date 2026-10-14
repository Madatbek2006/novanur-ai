import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nurnova_ai/core/audio/wav_encoder.dart';
import 'package:nurnova_ai/core/audio/wav_peaks.dart';
import 'package:nurnova_ai/core/speech/uzbek_text.dart';

void main() {
  group('latinToCyrillic', () {
    test('фразы приложения', () {
      expect(latinToCyrillic('Kitob javoni'), 'Китоб жавони');
      expect(latinToCyrillic('Qidirilmoqda: Stul'), 'Қидирилмоқда: Стул');
      expect(latinToCyrillic('Kamerani xonaga qarating'), 'Камерани хонага қаратинг');
    });

    test('сочетания: sh, ch, yo, yu, ya, ye', () {
      expect(latinToCyrillic('Shahar choyxona'), 'Шаҳар чойхона');
      expect(latinToCyrillic('yoz yulduz yangi yer'), 'ёз юлдуз янги ер');
    });

    test('oʻ и gʻ при любом апострофе', () {
      for (final a in ["'", '‘', 'ʻ', '’', '`']) {
        expect(latinToCyrillic('o${a}g${a}il'), 'ўғил', reason: a);
      }
      expect(latinToCyrillic("O'zbekiston"), 'Ўзбекистон');
    });

    test("yo' — это й и ў, а не ё", () {
      expect(latinToCyrillic("yo'l"), 'йўл');
    });

    test('апостроф после буквы — ъ, в том числе после «a»', () {
      expect(latinToCyrillic("ma'no"), 'маъно');
      // На бэке тут выходила латинская «a» с «ъ», и модель читала «ъло».
      expect(latinToCyrillic("a'lo"), 'аъло');
      expect(latinToCyrillic("sun'iy"), 'сунъий');
    });

    test("s'h — разделитель, а не ъ", () {
      expect(latinToCyrillic("Is'hoq"), 'Исҳоқ');
    });

    test('«e» в начале слова и после гласной — «э», иначе «е»', () {
      expect(latinToCyrillic('ekran'), 'экран');
      expect(latinToCyrillic('aeroport'), 'аэропорт');
      // На бэке вторая буква слова считалась началом: «Вэлосипед».
      expect(latinToCyrillic('Velosiped'), 'Велосипед');
      expect(latinToCyrillic('televizor'), 'телевизор');
    });

    test('кириллица и знаки не трогаются', () {
      expect(latinToCyrillic('Салом, дунё!'), 'Салом, дунё!');
    });
  });

  group('uzbekSpeechChunks', () {
    final alphabet = {
      for (final line in File('assets/tts/uz/tokens.txt').readAsLinesSync())
        if (line.isNotEmpty) line.substring(0, line.lastIndexOf(' ')),
    }..remove('|');

    test('ни знаков, ни пробелов по краям — из-за них было «дыхание»', () {
      final chunks = uzbekSpeechChunks(
        'Rasmda yorug‘ xona ko‘rinmoqda. Devor yonida kitob javoni turibdi, '
        'uning qarshisida esa katta televizor bor.',
        alphabet,
      );
      expect(chunks, [
        'расмда ёруғ хона кўринмоқда девор ёнида китоб жавони турибди '
            'унинг қаршисида эса катта телевизор бор',
      ]);
    });

    test('двоеточие не режет фразу и не оставляет пробела перед словом', () {
      expect(uzbekSpeechChunks('Qidirilmoqda: Stul', alphabet), ['қидирилмоқда стул']);
    });

    test('куски не длиннее лимита и режутся по предложениям', () {
      final text = List.filled(8, 'Bu juda uzun gap bo‘lib, uni bo‘lish kerak.').join(' ');
      final chunks = uzbekSpeechChunks(text, alphabet);
      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(uzbekChunkLimit));
        expect(chunk, isNot(startsWith(' ')));
        expect(chunk, isNot(endsWith(' ')));
      }
    });

    test('цифры и знаки не слепляют слова', () {
      expect(uzbekSpeechChunks('2026-yil, 5 ta stul', alphabet), ['йил та стул']);
    });

    test('нечего сказать — пусто', () {
      expect(uzbekSpeechChunks('... 123 !!!', alphabet), isEmpty);
      expect(uzbekSpeechChunks('   ', alphabet), isEmpty);
    });
  });

  group('encodeWav', () {
    test('куски с паузой — валидный WAV, который читает и полоса плеера', () {
      final a = Float32List.fromList(List.filled(1600, 0.5));
      final b = Float32List.fromList(List.filled(1600, -0.5));
      final wav = encodeWav([a, b], 16000, gap: const Duration(milliseconds: 80));

      final data = ByteData.sublistView(wav);
      expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
      expect(data.getUint32(24, Endian.little), 16000);
      expect(data.getUint16(34, Endian.little), 16);
      // 1600 + 1280 тишины + 1600 отсчётов по 2 байта.
      expect(data.getUint32(40, Endian.little), (1600 + 1280 + 1600) * 2);
      expect(wav.length, 44 + (1600 + 1280 + 1600) * 2);
      expect(data.getInt16(44, Endian.little), (0.5 * 32767).round());
      expect(data.getInt16(44 + (1600 + 100) * 2, Endian.little), 0); // пауза

      expect(peaksFromWav(wav, bars: 8), hasLength(8));
    });

    test('за пределами ±1 — обрезается, а не переполняется', () {
      final wav = encodeWav([Float32List.fromList([2.0, -3.0])], 16000);
      final data = ByteData.sublistView(wav);
      expect(data.getInt16(44, Endian.little), 32767);
      expect(data.getInt16(46, Endian.little), -32767);
    });
  });
}
