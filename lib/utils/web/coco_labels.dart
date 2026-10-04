import 'package:flutter/services.dart';

/// Names of the 80 COCO classes the web object detector reports, in the
/// app's languages. All lists share COCO's class order.
class CocoLabels {
  final List<String> _names;

  const CocoLabels._(this._names);

  /// As the detector reports them.
  static const List<String> _english = [
    'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck',
    'boat', 'traffic light', 'fire hydrant', 'stop sign', 'parking meter', 'bench',
    'bird', 'cat', 'dog', 'horse', 'sheep', 'cow', 'elephant', 'bear', 'zebra',
    'giraffe', 'backpack', 'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee',
    'skis', 'snowboard', 'sports ball', 'kite', 'baseball bat', 'baseball glove',
    'skateboard', 'surfboard', 'tennis racket', 'bottle', 'wine glass', 'cup',
    'fork', 'knife', 'spoon', 'bowl', 'banana', 'apple', 'sandwich', 'orange',
    'broccoli', 'carrot', 'hot dog', 'pizza', 'donut', 'cake', 'chair', 'couch',
    'potted plant', 'bed', 'dining table', 'toilet', 'tv', 'laptop', 'mouse',
    'remote', 'keyboard', 'cell phone', 'microwave', 'oven', 'toaster', 'sink',
    'refrigerator', 'book', 'clock', 'vase', 'scissors', 'teddy bear',
    'hair drier', 'toothbrush',
  ];

  static const List<String> _russian = [
    'человек', 'велосипед', 'автомобиль', 'мотоцикл', 'самолёт', 'автобус', 'поезд',
    'грузовик', 'лодка', 'светофор', 'пожарный гидрант', 'знак «Стоп»', 'паркомат',
    'скамейка', 'птица', 'кошка', 'собака', 'лошадь', 'овца', 'корова', 'слон',
    'медведь', 'зебра', 'жираф', 'рюкзак', 'зонт', 'сумка', 'галстук', 'чемодан',
    'фрисби', 'лыжи', 'сноуборд', 'мяч', 'воздушный змей', 'бейсбольная бита',
    'бейсбольная перчатка', 'скейтборд', 'доска для сёрфинга', 'теннисная ракетка',
    'бутылка', 'бокал', 'чашка', 'вилка', 'нож', 'ложка', 'миска', 'банан', 'яблоко',
    'бутерброд', 'апельсин', 'брокколи', 'морковь', 'хот-дог', 'пицца', 'пончик',
    'торт', 'стул', 'диван', 'комнатное растение', 'кровать', 'обеденный стол',
    'унитаз', 'телевизор', 'ноутбук', 'компьютерная мышь', 'пульт', 'клавиатура',
    'мобильный телефон', 'микроволновка', 'духовка', 'тостер', 'раковина',
    'холодильник', 'книга', 'часы', 'ваза', 'ножницы', 'плюшевый мишка', 'фен',
    'зубная щётка',
  ];

  /// Uzbek names come from the label map the app already ships.
  static Future<CocoLabels> load(String languageCode) async {
    switch (languageCode) {
      case 'ru':
        return const CocoLabels._(_russian);
      case 'uz':
        try {
          final lines = (await rootBundle.loadString('assets/models/labelmap.txt'))
              .split('\n')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty)
              .toList();
          if (lines.length == _english.length) return CocoLabels._(lines);
        } catch (_) {}
        return const CocoLabels._(_english);
      default:
        return const CocoLabels._(_english);
    }
  }

  static const CocoLabels english = CocoLabels._(_english);

  String localize(String label) {
    final index = _english.indexOf(label);
    final name = index < 0 ? label : _names[index];
    return name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);
  }
}
