import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nurnova_ai/core/objects/object_labels.dart';
import 'package:nurnova_ai/core/objects/object_search.dart';
import 'package:nurnova_ai/domain/models/dashboard/dashboard_button_data.dart';
import 'package:nurnova_ai/presentation/features/home/features/dashboard/dashboard_cubit.dart';

import 'support/fakes.dart';

void main() {
  final labels = ObjectLabels.fromJson(
    jsonDecode(File('assets/ml/object_labels.json').readAsStringSync())
        as Map<String, dynamic>,
  );
  String? first(String query, [String lang = 'uz']) {
    final found = searchObjects(labels, query, lang);
    return found.isEmpty ? null : found.first;
  }

  group('searchObjects', () {
    test('одно и то же на любом языке приложения', () {
      expect(first('stul'), 'Chair');
      expect(first('Стул', 'ru'), 'Chair');
      expect(first('chair', 'en'), 'Chair');
    });

    test('диктовка: окончания и лишние слова не мешают', () {
      expect(first('stulni'), 'Chair');
      expect(first('найди стул', 'ru'), 'Chair');
      expect(first('kitob javonini'), 'Bookcase');
      expect(first('где мой кошелёк', 'ru'), 'Wallet');
    });

    test('апостроф в узбекском любой: ‘ ʻ \' `', () {
      for (final typed in ['ko‘zoynak', 'koʻzoynak', "ko'zoynak", 'ko`zoynak']) {
        expect(labels.translate(first(typed)!, 'uz'), 'Ko‘zoynak', reason: typed);
      }
    });

    test('одинаковые названия — одной строкой', () {
      // «Eyewear» и «Glasses» в словаре оба «очки».
      final found = searchObjects(labels, 'очки', 'ru');
      final names = found.map((l) => labels.translate(l, 'ru')).toList();
      expect(names.where((n) => n == 'Очки'), hasLength(1));
    });

    test('по началу слова — пока печатает', () {
      final found = searchObjects(labels, 'кров', 'ru');
      expect(found, containsAll(['Bed', 'Infant bed']));
    });

    test('«kitob» — книга, а не кит', () {
      final found = searchObjects(labels, 'kitob', 'uz');
      expect(found.first, 'Book');
      expect(found, isNot(contains('Whale')));
      expect(first('kitoblarni'), 'Book');
    });

    test('неизвестное — пусто, а не первое попавшееся', () {
      expect(searchObjects(labels, 'qwertyuiop', 'uz'), isEmpty);
      expect(searchObjects(labels, '   ', 'uz'), isEmpty);
    });

    test('подсказки — только то, что детектор знает', () {
      for (final label in findSuggestions) {
        expect(labels.names, contains(label), reason: label);
      }
    });
  });

  group('DashboardCubit: поиск предмета', () {
    late FakeSpeaker speaker;
    late DashboardCubit cubit;
    final t0 = DateTime(2026);
    DateTime at(int ms) => t0.add(Duration(milliseconds: ms));

    setUp(() {
      registerCubitDependencies();
      speaker = FakeSpeaker();
      cubit = DashboardCubit(FakeRepository(), speaker);
      cubit.setDashboardButtonType(DashboardButtonType.findObject);
      cubit.setFindTarget('Chair', 'Stul', 'uz');
    });

    test('выбор предмета — говорит, что ищет', () {
      expect(cubit.states.findTarget, 'Chair');
      expect(cubit.states.findTargetName, 'Stul');
      expect(speaker.announced, hasLength(1));
    });

    test('появился в кадре — называет его, но не с первого кадра', () {
      speaker.announced.clear();
      cubit.onFindFrame(true, 'uz', now: at(0));
      expect(speaker.announced, isEmpty, reason: 'один кадр — может быть ошибкой');
      cubit.onFindFrame(true, 'uz', now: at(200));
      expect(speaker.announced, ['Stul']);
      expect(cubit.states.findTargetInView, isTrue);
    });

    test('пока в кадре — не повторяет; ушёл и вернулся — говорит снова', () {
      speaker.announced.clear();
      for (var ms = 0; ms <= 3000; ms += 200) {
        cubit.onFindFrame(true, 'uz', now: at(ms));
      }
      expect(speaker.announced, ['Stul']);

      for (var ms = 3200; ms <= 5600; ms += 200) {
        cubit.onFindFrame(false, 'uz', now: at(ms));
      }
      expect(cubit.states.findTargetInView, isFalse);

      cubit.onFindFrame(true, 'uz', now: at(5800));
      cubit.onFindFrame(true, 'uz', now: at(6000));
      expect(speaker.announced, ['Stul', 'Stul']);
    });

    test('потерялся на кадр — карточка не мигает', () {
      cubit.onFindFrame(true, 'uz', now: at(0));
      cubit.onFindFrame(false, 'uz', now: at(200));
      expect(cubit.states.findTargetInView, isTrue);
      cubit.onFindFrame(false, 'uz', now: at(1000));
      expect(cubit.states.findTargetInView, isFalse);
    });

    test('другой режим — поиск забыт', () {
      cubit.onFindFrame(true, 'uz', now: at(0));
      cubit.setDashboardButtonType(DashboardButtonType.objectRecognition);
      expect(cubit.states.findTarget, isNull);
      expect(cubit.states.findTargetInView, isFalse);
    });
  });
}
