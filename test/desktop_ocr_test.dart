import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nurnova_ai/utils/desktop/desktop_ocr.dart';

/// Настоящий Tesseract через FFI. Нужны libtesseract и словари:
///   flutter test test/desktop_ocr_test.dart \
///     --dart-define=NURNOVA_TESSERACT=/opt/homebrew/lib/libtesseract.5.dylib \
///     --dart-define=NURNOVA_DESKTOP_DATA=$PWD/desktop
/// Без libtesseract проверка пропускается.
void main() {
  const library = String.fromEnvironment('NURNOVA_TESSERACT');
  final photo = Platform.environment['OCR_PHOTO'] ?? 'test/fixtures/ocr_sample.png';
  final ready = library.isNotEmpty && File(photo).existsSync();

  test('читает узбекский и русский, проценты идут', () async {
    final progress = <double>[];
    final text = await DesktopOcr().recognize(
      File(photo).readAsBytesSync(),
      'uzb+rus',
      (status, value) {
        expect(status, startsWith('recognizing'));
        progress.add(value);
      },
    );
    // ignore: avoid_print
    print(text);
    expect(text, contains('havo'));
    expect(text, contains('Молоко'));
    expect(progress.first, 0);
    expect(progress.last, 1);
  }, skip: ready ? false : 'нет libtesseract / OCR_PHOTO');
}
