/// Узбекский текст для голоса MMS на телефоне.
///
/// Модель обучена на кириллице и знает только буквы и пробел: латиницу надо
/// перевести, а знаки препинания и цифры — убрать. Убирать их обязательно
/// самим: движок sherpa-onnx режет текст на точке, двоеточии, «?» и «!»,
/// оставляя пробел в начале следующего куска, а пробел на краю фразы модель
/// озвучивает вдохом — в середине и в конце было слышно «дыхание в микрофон».
library;

/// Сколько знаков в одном куске синтеза — как на сервере (`CHUNK_LIMIT` в
/// `app/services/tts.py`): дольше кусок — больше памяти на синтез.
const uzbekChunkLimit = 120;

/// Латиница → кириллица.
///
/// Перенос `latin_to_cyrillic` с бэка (`app/services/converter.py`) с двумя
/// исправлениями: там «a'» превращалось в латинскую «a» с «ъ» — латиницу
/// модель выбрасывала, и «a'lo» звучало как «ъло», — а «e» второй буквой
/// слова считалась началом слова: «Velosiped» → «Вэлосипед».
String latinToCyrillic(String text) {
  final s = text.replaceAll(RegExp('[‘’ʻʼ`´]'), "'");
  final out = StringBuffer();
  var i = 0;

  bool isLetter(int at) =>
      at >= 0 && at < s.length && RegExp(r'\p{L}', unicode: true).hasMatch(s[at]);
  String at(int index) => index < s.length ? s[index] : '';
  String cased(String source, String cyrillic) =>
      source == source.toUpperCase() && source != source.toLowerCase()
          ? cyrillic.toUpperCase()
          : cyrillic;

  while (i < s.length) {
    final c = s[i];
    final lower = c.toLowerCase();
    final next = at(i + 1).toLowerCase();

    // «yo'l» — это й + ў, а не ё.
    if (lower == 'y' && next == 'o' && at(i + 2) == "'") {
      out
        ..write(cased(c, 'й'))
        ..write(cased(at(i + 1), 'ў'));
      i += 3;
      continue;
    }
    if (next == "'" && (lower == 'o' || lower == 'g')) {
      out.write(cased(c, lower == 'o' ? 'ў' : 'ғ'));
      i += 2;
      continue;
    }
    final pair = _pairs[lower + next];
    if (pair != null) {
      out.write(cased(c, pair));
      i += 2;
      continue;
    }

    if (c == "'") {
      // «Is'hoq» — апостроф только разделяет «s» и «h»: Исҳоқ.
      // После буквы это тутуқ белгиси: «ma'no» → маъно. Иначе — кавычка.
      if (at(i - 1).toLowerCase() == 's' && next == 'h') {
        // разделитель — не пишем
      } else if (isLetter(i - 1)) {
        out.write('ъ');
      } else {
        out.write(c);
      }
      i += 1;
      continue;
    }

    if (lower == 'e') {
      // В начале слова и после гласной — «э»: экран, аэропорт.
      final afterConsonant =
          isLetter(i - 1) && !_vowels.contains(at(i - 1).toLowerCase());
      out.write(cased(c, afterConsonant ? 'е' : 'э'));
    } else {
      final single = _letters[lower];
      out.write(single == null ? c : cased(c, single));
    }
    i += 1;
  }
  return out.toString();
}

const _vowels = {'a', 'e', 'i', 'o', 'u'};

const _pairs = {
  'sh': 'ш',
  'ch': 'ч',
  'yo': 'ё',
  'yu': 'ю',
  'ya': 'я',
  'ye': 'е',
};

const _letters = {
  'a': 'а', 'b': 'б', 'c': 'с', 'd': 'д', 'f': 'ф', 'g': 'г', 'h': 'ҳ',
  'i': 'и', 'j': 'ж', 'k': 'к', 'l': 'л', 'm': 'м', 'n': 'н', 'o': 'о',
  'p': 'п', 'q': 'қ', 'r': 'р', 's': 'с', 't': 'т', 'u': 'у', 'v': 'в',
  'w': 'в', 'x': 'х', 'y': 'й', 'z': 'з',
};

/// Текст, готовый к синтезу: кириллица кусками не длиннее [limit], в каждом —
/// только знакомые модели знаки из [alphabet], без пробелов по краям.
///
/// Режет так же, как сервер (`app/utils/sentences.py`): по предложениям, а
/// слишком длинные — по запятым и в крайнем случае по словам. Знаки и цифры
/// становятся пробелами, чтобы не склеить соседние слова. Цифр модель толком
/// не знает (в словаре только 0–6), поэтому числа пропускаются.
List<String> uzbekSpeechChunks(
  String text,
  Set<String> alphabet, {
  int limit = uzbekChunkLimit,
}) {
  final chunks = _groupIntoChunks(_splitSentences(latinToCyrillic(text)), limit);
  return [
    for (final chunk in chunks)
      if (_clean(chunk, alphabet) case final cleaned when cleaned.isNotEmpty)
        cleaned,
  ];
}

String _clean(String chunk, Set<String> alphabet) {
  final out = StringBuffer();
  for (final rune in chunk.toLowerCase().runes) {
    final c = String.fromCharCode(rune);
    out.write(alphabet.contains(c) && !_digit.hasMatch(c) ? c : ' ');
  }
  return out.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

final _digit = RegExp(r'\d');
final _sentenceEnd = RegExp(r'(?<=[.!?…])\s+');
final _clauseEnd = RegExp(r'(?<=[,;:])\s+');

List<String> _splitSentences(String text) =>
    text.trim().split(_sentenceEnd).where((s) => s.trim().isNotEmpty).toList();

List<String> _groupIntoChunks(List<String> sentences, int limit) {
  final chunks = <String>[];
  var current = '';
  for (final sentence in sentences) {
    for (final piece in _fit(sentence, limit)) {
      if (current.isEmpty) {
        current = piece;
      } else if (current.length + 1 + piece.length <= limit) {
        current = '$current $piece';
      } else {
        chunks.add(current);
        current = piece;
      }
    }
  }
  if (current.isNotEmpty) chunks.add(current);
  return chunks;
}

List<String> _fit(String sentence, int limit) {
  if (sentence.length <= limit) return [sentence];
  final parts = <String>[];
  for (final raw in sentence.split(_clauseEnd)) {
    final clause = raw.trim();
    if (clause.isEmpty) continue;
    parts.addAll(clause.length <= limit ? [clause] : _splitByWords(clause, limit));
  }
  return parts.isEmpty ? _splitByWords(sentence, limit) : parts;
}

List<String> _splitByWords(String text, int limit) {
  final parts = <String>[];
  var current = '';
  for (final word in text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty)) {
    if (current.isEmpty) {
      // Слово длиннее лимита целиком — режем его, деваться некуда.
      var rest = word;
      while (rest.length > limit) {
        parts.add(rest.substring(0, limit));
        rest = rest.substring(limit);
      }
      current = rest;
    } else if (current.length + 1 + word.length <= limit) {
      current = '$current $word';
    } else {
      parts.add(current);
      current = word;
    }
  }
  if (current.isNotEmpty) parts.add(current);
  return parts;
}
