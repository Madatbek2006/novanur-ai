import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

/// Предметы модели «Предметы дома» — yolo26n, дообученной на HomeObjects-3K
/// (`tool/home_objects/train.py`), — в том порядке, в каком она выдаёт их
/// номера. Имена взяты из словаря `ObjectLabels`, поэтому перевод, рамки и
/// озвучка общие с обычным распознаванием предметов.
const homeObjectNames = <String>[
  'Bed',
  'Couch', // sofa
  'Chair',
  'Table',
  'Lamp',
  'Television', // tv
  'Laptop',
  'Wardrobe',
  'Window',
  'Door',
  'Houseplant', // potted plant
  'Picture frame', // photo frame
];

/// Раскладка байтов кадра: NV21 с камеры Android, BGRA с камеры iOS, RGBA —
/// картинка, открытая в десктопной версии.
enum FrameLayout { nv21, bgra8888, rgba8888 }

/// Кадр камеры как есть, плюс на сколько градусов его повернуть по часовой
/// стрелке, чтобы он встал как на экране.
class CameraFrame {
  const CameraFrame({
    required this.bytes,
    required this.width,
    required this.height,
    required this.bytesPerRow,
    required this.layout,
    required this.rotation,
  });

  final Uint8List bytes;
  final int width;
  final int height;
  final int bytesPerRow;
  final FrameLayout layout;
  final int rotation;

  bool get _sideways => rotation == 90 || rotation == 270;

  /// Размеры кадра, повёрнутого как на экране.
  int get uprightWidth => _sideways ? height : width;
  int get uprightHeight => _sideways ? width : height;
}

/// Как повёрнутый кадр вписан в квадратный вход модели: уменьшен с
/// сохранением пропорций, по краям — серые поля, как при обучении.
class Letterbox {
  Letterbox(this.width, this.height, this.side)
      : scale = math.min(side / width, side / height);

  final int width;
  final int height;
  final int side;
  final double scale;

  double get padX => (side - width * scale) / 2;
  double get padY => (side - height * scale) / 2;
}

/// Находка модели в координатах повёрнутого кадра.
class HomeObject {
  const HomeObject(this.name, this.confidence, this.box);

  final String name;
  final double confidence;
  final Rect box;
}

/// Серый цвет полей, которым YOLO добивает кадр до квадрата.
const _padding = 114 / 255;

/// Заполняет вход модели [1, 3, side, side] — три плоскости R, G, B, 0…1,
/// как в PyTorch, откуда модель выгружена, — кадром [frame]: поворачивает,
/// вписывает в квадрат и переводит цвет за один проход.
/// Берётся ближайший пиксель — для крупной мебели этого хватает, а кадр
/// готов за миллисекунды.
void fillInput(CameraFrame frame, Letterbox letterbox, Float32List input) {
  input.fillRange(0, input.length, _padding);

  final side = letterbox.side;
  final scale = letterbox.scale;
  final left = letterbox.padX.round();
  final top = letterbox.padY.round();
  final right = math.min(side, left + (letterbox.width * scale).round());
  final bottom = math.min(side, top + (letterbox.height * scale).round());

  // Какой пиксель повёрнутого кадра попадает в каждую колонку и строку входа.
  final ux = Int32List(side);
  for (var x = left; x < right; x++) {
    ux[x] = math.min(letterbox.width - 1, ((x - left + 0.5) / scale).floor());
  }
  final uy = Int32List(side);
  for (var y = top; y < bottom; y++) {
    uy[y] = math.min(letterbox.height - 1, ((y - top + 0.5) / scale).floor());
  }

  final bytes = frame.bytes;
  final stride = frame.bytesPerRow;
  final w = frame.width;
  final h = frame.height;
  final chroma = stride * h; // NV21: после яркости идут пары V, U
  final plane = side * side;

  for (var y = top; y < bottom; y++) {
    var o = y * side + left;
    for (var x = left; x < right; x++, o++) {
      // Пиксель исходного кадра, который после поворота оказался в (ux, uy).
      final int sx, sy;
      switch (frame.rotation) {
        case 90:
          sx = uy[y];
          sy = h - 1 - ux[x];
        case 180:
          sx = w - 1 - ux[x];
          sy = h - 1 - uy[y];
        case 270:
          sx = w - 1 - uy[y];
          sy = ux[x];
        default:
          sx = ux[x];
          sy = uy[y];
      }

      final double r, g, b;
      if (frame.layout == FrameLayout.rgba8888) {
        final p = sy * stride + sx * 4;
        r = bytes[p].toDouble();
        g = bytes[p + 1].toDouble();
        b = bytes[p + 2].toDouble();
      } else if (frame.layout == FrameLayout.bgra8888) {
        final p = sy * stride + sx * 4;
        b = bytes[p].toDouble();
        g = bytes[p + 1].toDouble();
        r = bytes[p + 2].toDouble();
      } else {
        final luma = bytes[sy * stride + sx].toDouble();
        final c = chroma + (sy >> 1) * stride + (sx & ~1);
        final v = bytes[c] - 128.0;
        final u = bytes[c + 1] - 128.0;
        r = luma + 1.402 * v;
        g = luma - 0.344136 * u - 0.714136 * v;
        b = luma + 1.772 * u;
      }
      input[o] = r.clamp(0, 255) / 255;
      input[plane + o] = g.clamp(0, 255) / 255;
      input[2 * plane + o] = b.clamp(0, 255) / 255;
    }
  }
}

/// Ниже этой уверенности находку не называем: незрячему ложный «диван»
/// хуже, чем пропущенный.
const homeObjectMinConfidence = 0.45;

/// Разбирает выход модели [1, N, 6] — x1, y1, x2, y2 в пикселях входа,
/// уверенность и номер предмета — в находки на повёрнутом кадре.
List<HomeObject> decodeHomeObjects(
  Float32List output,
  Letterbox letterbox, {
  double minConfidence = homeObjectMinConfidence,
  List<String> names = homeObjectNames,
}) {
  final found = <HomeObject>[];
  final scale = letterbox.scale;
  final padX = letterbox.padX;
  final padY = letterbox.padY;

  double toX(double v) =>
      ((v - padX) / scale).clamp(0, letterbox.width).toDouble();
  double toY(double v) =>
      ((v - padY) / scale).clamp(0, letterbox.height).toDouble();

  for (var i = 0; i + 5 < output.length; i += 6) {
    final confidence = output[i + 4];
    if (confidence < minConfidence) continue;
    final index = output[i + 5].round();
    if (index < 0 || index >= names.length) continue;

    final box = Rect.fromLTRB(
      toX(output[i]),
      toY(output[i + 1]),
      toX(output[i + 2]),
      toY(output[i + 3]),
    );
    if (box.isEmpty) continue;
    found.add(HomeObject(names[index], confidence, box));
  }
  found.sort((a, b) => b.confidence.compareTo(a.confidence));

  // YOLO26 сама не выдаёт повторных рамок, но на сложном кадре одно и то же
  // растение изредка приходит дважды почти одной рамкой. Оставляем ту, в
  // которой модель увереннее.
  final kept = <HomeObject>[];
  for (final o in found) {
    final repeat = kept.any((k) => k.name == o.name && _overlap(k.box, o.box) > 0.7);
    if (!repeat) kept.add(o);
  }
  return kept;
}

/// Доля пересечения двух рамок от их объединения.
double _overlap(Rect a, Rect b) {
  final i = a.intersect(b);
  if (i.width <= 0 || i.height <= 0) return 0;
  final shared = i.width * i.height;
  return shared / (a.width * a.height + b.width * b.height - shared);
}
