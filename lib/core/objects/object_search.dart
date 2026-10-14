import 'object_labels.dart';

/// Что предложить искать, пока пользователь ничего не ввёл: то, что чаще
/// всего ищут дома. Имена — из словаря детектора.
const findSuggestions = <String>[
  'Mobile phone',
  'Glasses',
  'Wallet',
  'Remote control',
  'Mug',
  'Bottle',
  'Book',
  'Backpack',
  'Handbag',
  'Laptop',
  'Chair',
  'Table',
  'Door',
  'Window',
  'Bed',
  'Couch',
  'Television',
  'Kettle',
  'Houseplant',
  'Person',
];

/// Ищет предмет по тому, что пользователь ввёл или продиктовал, — на любом
/// из языков приложения: «stul», «стул» и «chair» находят одно и то же.
///
/// Диктовка редко даёт голое слово: «stulni», «найди стул», «телефон
/// где-то тут». Поэтому, кроме совпадения целиком и по началу, предмет
/// находится и тогда, когда с его названия начинается одно из сказанных
/// слов — так проходят и окончания.
///
/// Возвращает английские имена, лучшие совпадения первыми. Предметы с одним
/// и тем же названием — «Eyewear» и «Glasses» оба «очки» — идут одной
/// строкой: пользователю их не различить, а ищутся они по названию.
List<String> searchObjects(ObjectLabels labels, String query, String languageCode) {
  final q = _normalize(query);
  if (q.isEmpty) return const [];
  final queryWords = q.split(' ');

  final ranked = <(double, String, String)>[];
  for (final english in labels.names) {
    double? best;
    for (final name in labels.namesOf(english)) {
      final rank = _rank(_normalize(name), q, queryWords);
      if (rank != null && (best == null || rank < best)) best = rank;
    }
    if (best != null) ranked.add((best, labels.translate(english, languageCode), english));
  }

  ranked.sort((a, b) {
    final byRank = a.$1.compareTo(b.$1);
    return byRank != 0 ? byRank : a.$2.compareTo(b.$2);
  });
  final shown = <String>{};
  return [
    for (final r in ranked)
      if (shown.add(r.$2)) r.$3,
  ];
}

double? _rank(String name, String query, List<String> queryWords) {
  if (name == query) return 0;
  if (name.startsWith(query)) return 1;
  final words = name.split(' ');
  if (words.any((w) => w.startsWith(query))) return 2;
  if (name.contains(query)) return 3;

  // Сказанное слово начинается с названия: «stulni» — «stul». Чем больше
  // слов названия так нашлось, тем точнее: «kitob javonini» — это книжный
  // шкаф, а не книга. Короткие названия так не ищем, и название должно быть
  // хотя бы половиной слова: иначе «kitob» находит «kit» — кита.
  final matched = words
      .where((w) =>
          w.length >= 4 &&
          queryWords.any((q) => q.startsWith(w) && w.length * 2 >= q.length))
      .length;
  if (matched == 0) return null;
  return 4 + (words.length - matched) * 0.1 - matched * 0.01;
}

String _normalize(String s) => s
    .toLowerCase()
    .replaceAll(RegExp("[‘’ʻʼ`´']"), "'")
    .replaceAll('ё', 'е')
    .replaceAll(RegExp(r"[^\p{L}\p{N}\s']", unicode: true), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
