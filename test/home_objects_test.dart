import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nurnova_ai/core/objects/home_objects.dart';

/// Кадр BGRA [width]×[height]: верхняя половина строк красная, нижняя синяя.
CameraFrame redOverBlue(int width, int height, int rotation) {
  final bytes = Uint8List(width * height * 4);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final p = (y * width + x) * 4;
      final red = y < height ~/ 2;
      bytes[p] = red ? 0 : 255; // B
      bytes[p + 1] = 0; // G
      bytes[p + 2] = red ? 255 : 0; // R
      bytes[p + 3] = 255;
    }
  }
  return CameraFrame(
    bytes: bytes,
    width: width,
    height: height,
    bytesPerRow: width * 4,
    layout: FrameLayout.bgra8888,
    rotation: rotation,
  );
}

void main() {
  const side = 8;
  // Вход модели — три плоскости R, G, B во float32, поэтому сравниваем с
  // точностью до округления.
  List<double> pixel(Float32List input, int x, int y) {
    final o = y * side + x;
    return [
      for (var c = 0; c < 3; c++)
        (input[c * side * side + o] * 1e6).roundToDouble() / 1e6,
    ];
  }

  const red = [1.0, 0.0, 0.0];
  const blue = [0.0, 0.0, 1.0];
  final gray = List.filled(3, (114 / 255 * 1e6).roundToDouble() / 1e6);

  group('Letterbox', () {
    test('портретный кадр телефона вписывается по высоте, поля по бокам', () {
      final box = Letterbox(720, 1280, 320);
      expect(box.scale, 0.25);
      expect(box.padX, 70);
      expect(box.padY, 0);
    });
  });

  group('fillInput поворачивает кадр как на экране', () {
    // Камера телефона отдаёт кадр лёжа; модель учили на стоячих фото.
    // Повернуть надо так же, как ML Kit, иначе рамки не лягут на превью.

    test('без поворота: красное сверху', () {
      final frame = redOverBlue(8, 8, 0);
      final input = Float32List(side * side * 3);
      fillInput(frame, Letterbox(8, 8, side), input);
      expect(pixel(input, 4, 0), red);
      expect(pixel(input, 4, 7), blue);
    });

    test('90° по часовой: верх кадра уходит вправо', () {
      final frame = redOverBlue(8, 4, 90); // лёжа: 8 в ширину, 4 в высоту
      final input = Float32List(side * side * 3);
      final box = Letterbox(frame.uprightWidth, frame.uprightHeight, side);
      expect((frame.uprightWidth, frame.uprightHeight), (4, 8));
      fillInput(frame, box, input);
      // Стоячий кадр 4×8 занимает середину квадрата, по бокам серые поля.
      expect(pixel(input, 0, 4), gray);
      expect(pixel(input, 7, 4), gray);
      expect(pixel(input, 2, 4), blue);
      expect(pixel(input, 5, 4), red);
    });

    test('270°: верх кадра уходит влево', () {
      final frame = redOverBlue(8, 4, 270);
      final input = Float32List(side * side * 3);
      fillInput(frame, Letterbox(4, 8, side), input);
      expect(pixel(input, 2, 4), red);
      expect(pixel(input, 5, 4), blue);
    });

    test('180°: верх кадра уходит вниз', () {
      final frame = redOverBlue(8, 8, 180);
      final input = Float32List(side * side * 3);
      fillInput(frame, Letterbox(8, 8, side), input);
      expect(pixel(input, 4, 0), blue);
      expect(pixel(input, 4, 7), red);
    });
  });

  group('fillInput: цвет из NV21', () {
    CameraFrame nv21(int luma, int u, int v) {
      const w = 8, h = 8;
      final bytes = Uint8List(w * h * 3 ~/ 2);
      bytes.fillRange(0, w * h, luma);
      for (var i = w * h; i < bytes.length; i += 2) {
        bytes[i] = v; // NV21: сначала V
        bytes[i + 1] = u;
      }
      return CameraFrame(
        bytes: bytes,
        width: w,
        height: h,
        bytesPerRow: w,
        layout: FrameLayout.nv21,
        rotation: 0,
      );
    }

    test('серый остаётся серым', () {
      final input = Float32List(side * side * 3);
      fillInput(nv21(200, 128, 128), Letterbox(8, 8, side), input);
      for (final c in pixel(input, 3, 3)) {
        expect(c, closeTo(200 / 255, 1e-6));
      }
    });

    test('V выше середины — красный, а не синий', () {
      final input = Float32List(side * side * 3);
      fillInput(nv21(128, 128, 200), Letterbox(8, 8, side), input);
      final [r, g, b] = pixel(input, 3, 3);
      expect(r, greaterThan(0.8));
      expect(b, closeTo(128 / 255, 1e-6));
      expect(g, lessThan(b));
    });
  });

  group('decodeHomeObjects', () {
    final box = Letterbox(720, 1280, 320);

    test('уверенная находка переводится в координаты кадра', () {
      final output = Float32List.fromList([
        // диван: x1, y1, x2, y2 в пикселях входа, уверенность, класс
        70 + 18, 40, 70 + 90, 200, 0.9, 1,
        // неуверенный стул — не называем
        100, 100, 160, 160, 0.2, 2,
        // пустые строки в конце выхода
        0, 0, 0, 0, 0, 0,
      ]);
      final found = decodeHomeObjects(output, box);
      expect(found, hasLength(1));
      expect(found.single.name, 'Couch');
      expect(found.single.confidence, closeTo(0.9, 1e-6));
      final r = found.single.box;
      expect(r.left, closeTo(72, 1e-3));
      expect(r.top, closeTo(160, 1e-3));
      expect(r.right, closeTo(360, 1e-3));
      expect(r.bottom, closeTo(800, 1e-3));
    });

    test('рамка на поле обрезается по кадру, чужой номер класса — отброшен', () {
      final output = Float32List.fromList([
        0, 0, 100, 320, 0.8, 9, // дверь, заходит на левое поле
        130, 130, 190, 190, 0.99, 42, // такого предмета модель не знает
      ]);
      final found = decodeHomeObjects(output, box);
      expect(found.single.name, 'Door');
      expect(found.single.box, const Rect.fromLTRB(0, 0, 120, 1280));
    });

    test('сначала самые уверенные', () {
      final output = Float32List.fromList([
        100, 100, 160, 160, 0.5, 2, // стул
        100, 100, 160, 160, 0.95, 0, // кровать на том же месте
      ]);
      expect(decodeHomeObjects(output, box).map((o) => o.name), ['Bed', 'Chair']);
    });

    test('почти та же рамка того же предмета — одна находка, а не две', () {
      // Так модель на втором эпохе нашла одно растение дважды.
      final output = Float32List.fromList([
        124.9, 131.5, 151.1, 174.7, 0.75, 10,
        125.6, 130.5, 150.7, 173.2, 0.70, 10,
        52.1, 41.3, 111.4, 222.1, 0.75, 10, // другое растение рядом
      ]);
      final found = decodeHomeObjects(output, box);
      expect(found.map((o) => o.confidence), [closeTo(0.75, 1e-6), closeTo(0.75, 1e-6)]);
    });
  });

  test('у всех предметов модели есть перевод в общем словаре', () {
    final labels = jsonDecode(File('assets/ml/object_labels.json').readAsStringSync())
        as Map<String, dynamic>;
    for (final name in homeObjectNames) {
      expect(labels, contains(name), reason: name);
    }
    expect(homeObjectNames, hasLength(12));
  });
}
