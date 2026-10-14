import 'dart:convert';

import 'package:flutter/services.dart';

/// Названия предметов, которые узнаёт детектор на телефоне, на языках
/// приложения.
///
/// Детектор отвечает по-английски — это 630 классов Open Images. Показывать и
/// произносить их надо на языке пользователя, поэтому рядом с моделью лежит
/// словарь `assets/ml/object_labels.json`.
class ObjectLabels {
  ObjectLabels._(this._names);

  final Map<String, Map<String, String>> _names;

  static const asset = 'assets/ml/object_labels.json';

  /// Пока настоящий словарь не загружен, названия остаются английскими.
  static final ObjectLabels english = ObjectLabels._(const {});

  static Future<ObjectLabels> load() async {
    final raw = jsonDecode(await rootBundle.loadString(asset)) as Map<String, dynamic>;
    return ObjectLabels.fromJson(raw);
  }

  factory ObjectLabels.fromJson(Map<String, dynamic> json) => ObjectLabels._({
        for (final entry in json.entries)
          entry.key: Map<String, String>.from(entry.value as Map),
      });

  /// Название на языке [languageCode], а если перевода нет — как есть.
  String translate(String english, String languageCode) =>
      _names[english]?[languageCode] ?? english;

  int get length => _names.length;

  /// Английские имена всех предметов словаря — так их отдаёт детектор.
  Iterable<String> get names => _names.keys;

  /// Предмет на всех языках: английское имя и переводы.
  Iterable<String> namesOf(String english) => [english, ...?_names[english]?.values];

  /// Самая конкретная из меток предмета. Метки идут, как их отдаёт детектор:
  /// по убыванию уверенности.
  ///
  /// Детектор почти всегда ставит первой широкую категорию: книжная полка
  /// приходит как «Furniture 0.99, Shelf 0.99, Bookcase 0.76». Если брать
  /// первую, и полка, и тумба называются одинаково — «мебель», и вся
  /// детальность модели теряется. Поэтому берём самую узкую метку, если она
  /// достаточно уверенная, и откатываемся к широкой, только когда узкой нет.
  static String? pickLabel(List<(String, double)> labels) {
    if (labels.isEmpty) return null;

    var best = labels.first;
    for (final label in labels.skip(1)) {
      if (label.$2 >= _minSpecificConfidence && _tier(label.$1) < _tier(best.$1)) {
        best = label;
      }
    }
    return best.$1;
  }

  /// Насколько уверенной должна быть узкая метка, чтобы заменить широкую.
  /// Замер на книжной полке: «Bookcase» приходит с 0.61–0.79.
  static const _minSpecificConfidence = 0.6;

  static int _tier(String label) =>
      _broad.contains(label) ? 2 : (_parent.contains(label) ? 1 : 0);

  /// Широкие категории: сами по себе почти ничего не говорят.
  static const _broad = {
    'Furniture', 'Home appliance', 'Kitchen Appliance', 'Tableware',
    'Clothing', 'Footwear', 'Outerwear', 'Food', 'Fruit', 'Vegetable', 'Drink',
    'Dessert', 'Snack', 'Baked goods', 'Dairy', 'Plant', 'Insect', 'Building',
    'Toy', 'Weapon', 'Container', 'Packaged goods', 'Electronic device',
    'Display device', 'Luggage & bags', 'Jewellery', 'Hardware', 'Lighting',
    'Eyewear',
  };

  /// Названия, у которых есть уточнения: «полка» — и «книжный шкаф»,
  /// «стол» — и «журнальный столик», «мяч» — и «футбольный мяч».
  static const _parent = {
    'Shelf', 'Cabinetry', 'Table', 'Hat', 'Bag', 'Ball', 'Fish', 'Bottle',
    'Clock', 'Car', 'Telephone', 'Camera', 'Helmet', 'Bed', 'Couch', 'Bear',
    'Turtle', 'Glasses', 'Shoe', 'Kettle', 'Knife', 'Racket', 'cup',
  };
}
