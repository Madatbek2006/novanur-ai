import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/core/objects/object_announcer.dart';
import 'package:nurnova_ai/core/objects/object_labels.dart';
import 'package:nurnova_ai/domain/models/dashboard/dashboard_button_data.dart';
import 'package:nurnova_ai/presentation/features/home/features/dashboard/dashboard_cubit.dart';

import 'support/fakes.dart';

void main() {
  group('ObjectLabels.pickLabel', () {
    test('книжная полка — это книжный шкаф, а не «мебель»', () {
      // Ровно то, что детектор отдал на эмуляторе.
      expect(
        ObjectLabels.pickLabel([('Furniture', 0.99), ('Shelf', 0.99), ('Bookcase', 0.76)]),
        'Bookcase',
      );
    });

    test('неуверенное уточнение не вытесняет надёжное', () {
      expect(
        ObjectLabels.pickLabel([('Furniture', 0.99), ('Shelf', 0.99), ('Bookcase', 0.55)]),
        'Shelf',
      );
    });

    test('тумба — шкаф', () {
      expect(ObjectLabels.pickLabel([('Furniture', 0.99), ('Cabinetry', 0.87)]), 'Cabinetry');
    });

    test('если уточнения нет, остаётся широкая метка', () {
      expect(ObjectLabels.pickLabel([('Furniture', 0.99)]), 'Furniture');
      expect(ObjectLabels.pickLabel([]), isNull);
    });

    test('конкретная метка первой — она и остаётся', () {
      expect(ObjectLabels.pickLabel([('Electric kettle', 0.9), ('Home appliance', 0.8)]),
          'Electric kettle');
    });
  });

  group('словарь меток', () {
    late ObjectLabels labels;
    late Map<String, dynamic> raw;

    setUpAll(() {
      raw = jsonDecode(File('assets/ml/object_labels.json').readAsStringSync())
          as Map<String, dynamic>;
      labels = ObjectLabels.fromJson(raw);
    });

    test('все 630 меток модели переведены на русский и узбекский', () {
      expect(labels.length, 630);
      for (final entry in raw.entries) {
        final names = Map<String, String>.from(entry.value as Map);
        expect(names['ru']?.trim(), isNotEmpty, reason: entry.key);
        expect(names['uz']?.trim(), isNotEmpty, reason: entry.key);
      }
    });

    test('переводит и не теряет непереведённое', () {
      expect(labels.translate('Bookcase', 'ru'), 'Книжный шкаф');
      expect(labels.translate('Electric kettle', 'uz'), 'Elektr choynak');
      expect(labels.translate('Bookcase', 'en'), 'Bookcase');
      expect(labels.translate('Чего-то нет', 'ru'), 'Чего-то нет');
    });
  });

  group('ObjectAnnouncer', () {
    final t0 = DateTime(2026);
    DateTime at(num seconds) => t0.add(Duration(milliseconds: (seconds * 1000).round()));

    test('предмет называется, когда продержался два кадра', () {
      final announcer = ObjectAnnouncer();
      expect(announcer.update(['Стул'], at(0)), isEmpty);
      expect(announcer.update(['Стул'], at(0.2)), ['Стул']);
    });

    test('мелькнувшее на один кадр не называется', () {
      final announcer = ObjectAnnouncer();
      announcer.update(['Кошка'], at(0));
      expect(announcer.update(['Стул'], at(0.2)), isEmpty);
      expect(announcer.update(['Стул'], at(0.4)), ['Стул']);
    });

    test('пока предмет в кадре, повторно не называется', () {
      final announcer = ObjectAnnouncer();
      announcer.update(['Стул'], at(0));
      announcer.update(['Стул'], at(0.2));
      for (var i = 1; i <= 30; i++) {
        expect(announcer.update(['Стул'], at(0.2 + i * 0.3)), isEmpty, reason: 'кадр $i');
      }
    });

    test('ушёл из кадра и вернулся — называется снова', () {
      final announcer = ObjectAnnouncer();
      announcer.update(['Стул'], at(0));
      announcer.update(['Стул'], at(0.2));
      announcer.update(const <String>[], at(1));
      announcer.update(['Стул'], at(4));
      expect(announcer.update(['Стул'], at(4.2)), ['Стул']);
    });

    test('несколько новых предметов — одной порцией', () {
      final announcer = ObjectAnnouncer();
      announcer.update(['Стул', 'Стол'], at(0));
      expect(announcer.update(['Стул', 'Стол'], at(0.2)), ['Стул', 'Стол']);
    });
  });

  group('DashboardCubit и предметы', () {
    late FakeSpeaker speaker;
    late DashboardCubit cubit;

    setUp(() {
      registerCubitDependencies();
      speaker = FakeSpeaker();
      cubit = DashboardCubit(FakeRepository(), speaker, announceAfter: Duration.zero);
      cubit.setDashboardButtonType(DashboardButtonType.objectRecognition);
    });

    test('новые предметы называются одной фразой и не повторяются', () async {
      cubit.onObjectsInView(['Стул', 'Стол'], 'ru');
      cubit.onObjectsInView(['Стул', 'Стол'], 'ru');
      await pumpEventQueue();
      expect(speaker.announced, ['Стул, Стол']);
      expect(cubit.states.objectsInView, ['Стул', 'Стол']);

      cubit.onObjectsInView(['Стул', 'Стол'], 'ru');
      await pumpEventQueue();
      expect(speaker.announced, hasLength(1));
    });

    test('второе нажатие называет всё, что в кадре', () async {
      cubit.onObjectsInView(['Стул', 'Стол'], 'ru');
      cubit.readObjectsInView();
      expect(speaker.spoken, ['Стул, Стол']);
    });

    test('в пустом кадре второе нажатие подсказывает, что делать', () {
      cubit.readObjectsInView();
      expect(speaker.spoken, isEmpty);
      expect(speaker.announced, hasLength(1));
    });

    test('порядок в карточке не прыгает вслед за детектором', () {
      cubit.onObjectsInView(['Шкаф', 'Книжный шкаф'], 'ru');
      cubit.onObjectsInView(['Книжный шкаф', 'Шкаф'], 'ru');
      expect(cubit.states.objectsInView, ['Шкаф', 'Книжный шкаф']);

      cubit.onObjectsInView(['Стул', 'Книжный шкаф'], 'ru');
      expect(cubit.states.objectsInView, ['Книжный шкаф', 'Стул']);
    });

    test('смена режима очищает карточку', () async {
      cubit.onObjectsInView(['Стул'], 'ru');
      cubit.setDashboardButtonType(DashboardButtonType.scanText);
      expect(cubit.states.objectsInView, isEmpty);
    });

    test('«Предметы дома» — та же карточка, но своя подсказка', () async {
      cubit.onObjectsInView(['Стул'], 'ru');
      // Из обычных предметов в «Предметы дома»: прошлые находки не в счёт.
      cubit.setDashboardButtonType(DashboardButtonType.homeObjects);
      expect(cubit.states.objectsInView, isEmpty);

      cubit.readObjectsInView();
      expect(speaker.announced, [Strings.homeObjectsCameraHint]);
      expect(Strings.homeObjectsCameraHint, isNot(Strings.webObjectsCameraHint));

      cubit.onObjectsInView(['Диван'], 'ru');
      cubit.onObjectsInView(['Диван'], 'ru');
      await pumpEventQueue();
      expect(speaker.announced.last, 'Диван');
    });
  });
}
