import 'dart:ui';

import 'package:baiqavisit/presentation/features/web/dashboard/web_dashboard_cubit.dart';
import 'package:baiqavisit/utils/web/browser_vision_models.dart';
import 'package:baiqavisit/utils/web/coco_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VisionBarcode.isProductCode', () {
    test('EAN and UPC digits can be looked up', () {
      expect(const VisionBarcode(text: '5449000000996', format: 'ean_13').isProductCode, isTrue);
      expect(const VisionBarcode(text: '12345670', format: 'ean_8').isProductCode, isTrue);
    });

    test('links and short numbers cannot', () {
      expect(const VisionBarcode(text: 'https://example.com', format: 'qr_code').isProductCode, isFalse);
      expect(const VisionBarcode(text: '1234', format: 'code_128').isProductCode, isFalse);
    });
  });

  group('BrowserCameraStatus', () {
    test('parses the helper\'s codes and falls back to error', () {
      expect(BrowserCameraStatus.parse('granted'), BrowserCameraStatus.granted);
      expect(BrowserCameraStatus.parse('insecure'), BrowserCameraStatus.insecure);
      expect(BrowserCameraStatus.parse('something new'), BrowserCameraStatus.error);
      expect(BrowserCameraStatus.parse(null), BrowserCameraStatus.error);
    });

    test('only granted and prompt can start the camera', () {
      final startable = BrowserCameraStatus.values.where((s) => s.canStart);
      expect(startable, [BrowserCameraStatus.granted, BrowserCameraStatus.prompt]);
    });
  });

  group('CocoLabels', () {
    test('English names are capitalised', () async {
      final labels = await CocoLabels.load('en');
      expect(labels.localize('cell phone'), 'Cell phone');
    });

    test('Russian names, unknown labels pass through', () async {
      final labels = await CocoLabels.load('ru');
      expect(labels.localize('dog'), 'Собака');
      expect(labels.localize('teddy bear'), 'Плюшевый мишка');
      expect(labels.localize('spaceship'), 'Spaceship');
    });

    test('Uzbek names come from the shipped label map', () async {
      final labels = await CocoLabels.load('uz');
      expect(labels.localize('person'), 'Shaxs');
      expect(labels.localize('cat'), 'Mushuk');
      expect(labels.localize('toothbrush'), 'Tish cho‘tka');
    });
  });

  test('objects summary groups by name, most frequent first', () {
    const state = WebDashboardState(
      objects: VisionObjects(
        imageSize: Size(100, 100),
        objects: [
          VisionObject(label: 'cat', score: 0.9, box: Rect.zero),
          VisionObject(label: 'dog', score: 0.8, box: Rect.zero),
          VisionObject(label: 'dog', score: 0.7, box: Rect.zero),
        ],
      ),
    );
    expect(state.objectsSummary, 'Dog (2), Cat');
  });
}
