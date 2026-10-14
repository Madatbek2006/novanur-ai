import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nurnova_ai/core/barcode/barcode_repeat_filter.dart';
import 'package:nurnova_ai/core/barcode/product_code.dart';
import 'package:nurnova_ai/data/datasource/network/dto/barcode/product_response.dart';
import 'package:nurnova_ai/domain/models/dashboard/dashboard_button_data.dart';
import 'package:nurnova_ai/presentation/features/home/features/dashboard/dashboard_cubit.dart';

import 'support/fakes.dart';

void main() {
  group('isProductCode', () {
    test('EAN и UPC ищутся в базе', () {
      expect(isProductCode('5449000000996'), isTrue); // EAN-13
      expect(isProductCode('96385074'), isTrue); // EAN-8
      expect(isProductCode('012345678905'), isTrue); // UPC-A
    });

    test('ссылки, текст и короткие числа — нет', () {
      expect(isProductCode('https://example.com'), isFalse);
      expect(isProductCode('Wi-Fi: home'), isFalse);
      expect(isProductCode('1234'), isFalse);
    });
  });

  group('BarcodeRepeatFilter', () {
    final t0 = DateTime(2026);
    Duration s(num seconds) => Duration(milliseconds: (seconds * 1000).round());

    test('новый код называется сразу', () {
      final filter = BarcodeRepeatFilter();
      expect(filter.shouldReport('A', t0), isTrue);
    });

    test('пока код в кадре, повторно не называется — даже долго', () {
      final filter = BarcodeRepeatFilter();
      filter.shouldReport('A', t0);
      // Камера держится на упаковке 10 секунд, кадр каждые полсекунды.
      for (var i = 1; i <= 20; i++) {
        expect(filter.shouldReport('A', t0.add(s(i * 0.5))), isFalse,
            reason: 'кадр $i');
      }
    });

    test('убрал камеру и навёл снова — называется опять', () {
      // Раньше тот же код второй раз не назывался никогда.
      final filter = BarcodeRepeatFilter();
      filter.shouldReport('A', t0);
      expect(filter.shouldReport('A', t0.add(s(3.5))), isTrue);
    });

    test('другой код называется сразу', () {
      final filter = BarcodeRepeatFilter();
      filter.shouldReport('A', t0);
      expect(filter.shouldReport('B', t0.add(s(0.1))), isTrue);
      expect(filter.shouldReport('A', t0.add(s(0.2))), isTrue);
    });

    test('после сброса тот же код называется снова', () {
      final filter = BarcodeRepeatFilter();
      filter.shouldReport('A', t0);
      filter.reset();
      expect(filter.shouldReport('A', t0.add(s(0.1))), isTrue);
    });
  });

  group('ProductResponse.nameFor', () {
    test('берёт название на языке приложения', () {
      const product = ProductResponse(
        productName: 'Coca-Cola Original',
        productNameRu: 'Coca Cola',
      );
      expect(product.nameFor('ru'), 'Coca Cola');
      expect(product.nameFor('en'), 'Coca-Cola Original');
    });

    test('пустое название — не название', () {
      // Раньше пустая строка уходила в озвучку, и та молчала.
      expect(const ProductResponse(productName: '  ').nameFor('ru'), isNull);
      expect(
        const ProductResponse(productNameUz: '', productName: 'Milk').nameFor('uz'),
        'Milk',
      );
    });
  });

  group('DashboardCubit и штрихкод', () {
    late FakeRepository repository;
    late FakeSpeaker speaker;
    late DashboardCubit cubit;

    setUp(() {
      registerCubitDependencies();
      repository = FakeRepository();
      speaker = FakeSpeaker();
      cubit = DashboardCubit(repository, speaker);
    });

    test('товар найден — показывает и называет его на языке приложения', () async {
      repository.products['5449000000996'] =
          const ProductResponse(productName: 'Coca-Cola Original', productNameRu: 'Coca Cola');

      cubit.onBarcode('5449000000996', 'ru');
      expect(cubit.states.barcodeLookup, BarcodeLookup.searching);
      await pumpEventQueue();

      expect(cubit.states.barcodeLookup, BarcodeLookup.product);
      expect(cubit.states.barcodeText, 'Coca Cola');
      expect(speaker.spoken, ['Coca Cola']);
    });

    test('товара нет в базе — говорит об этом, а не молчит', () async {
      cubit.onBarcode('4780000000001', 'ru');
      await pumpEventQueue();

      expect(cubit.states.barcodeLookup, BarcodeLookup.notFound);
      expect(speaker.announced, hasLength(1));
      expect(speaker.spoken, isEmpty);
    });

    test('нет связи — говорит об ошибке, а не молчит', () async {
      repository.fail = true;
      cubit.onBarcode('5449000000996', 'ru');
      await pumpEventQueue();

      expect(cubit.states.barcodeLookup, BarcodeLookup.failed);
      expect(speaker.announced, hasLength(1));
    });

    test('QR со ссылкой не ищется как товар, а читается', () async {
      cubit.onBarcode('https://nurnova-ai.nurnova.workers.dev', 'ru');
      await pumpEventQueue();

      expect(repository.lookups, isEmpty);
      expect(cubit.states.barcodeLookup, BarcodeLookup.text);
      expect(speaker.spoken, ['https://nurnova-ai.nurnova.workers.dev']);
    });

    test('код, пойманный во время поиска, ищется следом, а не теряется', () async {
      repository.products['111111111111'] = const ProductResponse(productName: 'Первый');
      repository.products['222222222222'] = const ProductResponse(productName: 'Второй');
      repository.gate = Completer<void>();

      cubit.onBarcode('111111111111', 'ru');
      cubit.onBarcode('222222222222', 'ru'); // пока первый ещё ищется
      repository.gate!.complete();
      await pumpEventQueue();

      expect(repository.lookups, ['111111111111', '222222222222']);
      expect(cubit.states.barcodeText, 'Второй');
      expect(speaker.spoken, ['Первый', 'Второй']);
    });

    test('уход из режима штрихкода сбрасывает карточку и умолкает', () async {
      repository.products['5449000000996'] = const ProductResponse(productName: 'Cola');
      cubit.onBarcode('5449000000996', 'ru');
      await pumpEventQueue();

      cubit.setDashboardButtonType(DashboardButtonType.scanText);

      expect(cubit.states.barcodeLookup, BarcodeLookup.waiting);
      expect(cubit.states.barcode, isNull);
      expect(speaker.stops, greaterThan(0));
    });
  });
}
