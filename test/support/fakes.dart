import 'dart:async';

import 'package:logger/logger.dart';
import 'package:nurnova_ai/data/datasource/network/dto/barcode/product_response.dart';
import 'package:nurnova_ai/data/repositories/photo_analysis_repository.dart';
import 'package:nurnova_ai/domain/models/chat/speech_playback.dart';
import 'package:nurnova_ai/presentation/application/di/get_it_injection.dart';
import 'package:nurnova_ai/presentation/features/common/chat/chat_speaker.dart';
import 'package:nurnova_ai/presentation/support/state_message/state_message_manager.dart';

/// Базовый куб берёт логгер и менеджер сообщений из get_it.
void registerCubitDependencies() {
  if (getIt.isRegistered<Logger>()) return;
  getIt.registerSingleton<Logger>(Logger(level: Level.off));
  getIt.registerSingleton<StateMessageManager>(FakeMessages());
}

class FakeRepository implements PhotoAnalysisRepository {
  final products = <String, ProductResponse>{};
  final lookups = <String>[];
  bool fail = false;
  Completer<void>? gate;

  @override
  Future<ProductResponse?> getProduct(String barcode) async {
    lookups.add(barcode);
    final wait = gate;
    if (wait != null && lookups.length == 1) await wait.future;
    if (fail) throw Exception('нет сети');
    return products[barcode];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSpeaker implements ChatSpeaker {
  final spoken = <String>[];
  final announced = <String>[];
  int stops = 0;

  @override
  Future<void> speak(String? messageId, String text, String languageCode) async =>
      spoken.add(text);

  @override
  Future<void> announce(String text, String languageCode) async =>
      announced.add(text);

  @override
  Future<void> stop() async => stops++;

  @override
  Future<void> dispose() async {}

  @override
  void Function(SpeechPlayback?)? onPlayback;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeMessages implements StateMessageManager {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
