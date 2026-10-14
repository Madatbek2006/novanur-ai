import 'dart:async';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nurnova_ai/core/barcode/product_code.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/core/gen/localization/strings_locale_keys.g.dart';
import 'package:nurnova_ai/core/objects/object_announcer.dart';
import 'package:nurnova_ai/data/repositories/photo_analysis_repository.dart';
import 'package:nurnova_ai/domain/models/chat/speech_playback.dart';
import 'package:nurnova_ai/domain/models/dashboard/dashboard_button_data.dart';
import 'package:nurnova_ai/presentation/features/common/chat/chat_speaker.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_cubit.dart';

part 'dashboard_cubit.freezed.dart';

part 'dashboard_state.dart';

/// Dashboard screen state only. The camera is owned by the page through
/// `AppCameraController` — see `app_camera_controller.dart`.
@injectable
class DashboardCubit extends BaseCubit<DashboardState, DashboardEvent> {
  DashboardCubit(
    this._photoAnalysisRepository,
    this._speaker, {
    this.announceAfter = const Duration(milliseconds: 600),
  }) : super(const DashboardState()) {
    _speaker.onPlayback = (playback) {
      if (isClosed) return;
      updateState((state) => state.copyWith(
            playback: playback,
            speechClips: _speaker.clips,
          ));
    };
  }

  final PhotoAnalysisRepository _photoAnalysisRepository;

  /// Тот же голос, что у чата. Раньше здесь был голый FlutterTts: без языка,
  /// без скорости из настроек, и узбекское название товара не звучало вовсе.
  final ChatSpeaker _speaker;

  String _languageCode = 'en';

  /// Код, пойманный, пока искался предыдущий. Раньше такой код молча
  /// пропадал; теперь его ищут следом.
  String? _pendingBarcode;

  final ObjectAnnouncer _announcer = ObjectAnnouncer();

  /// Предметы, которые пора назвать, копятся короткое время и звучат одной
  /// фразой: «стул, стол». Иначе второй предмет, появившийся через мгновение
  /// после первого, обрывал бы его на полуслове.
  final List<String> _toAnnounce = [];
  Timer? _announceTimer;
  final Duration announceAfter;

  @override
  Future<void> close() async {
    _announceTimer?.cancel();
    _speaker.onPlayback = null;
    await _speaker.dispose();
    return super.close();
  }

  void setDashboardButtonType(DashboardButtonType type) {
    // Каждый режим начинает с чистого листа: результат прошлого режима не
    // должен ни висеть на экране, ни звучать.
    if (type != states.type) {
      _resetBarcode();
      _resetObjects();
      _resetFind();
    }
    updateState((state) => state.copyWith(type: type));
  }

  void setTakenPhoto(XFile photo) {
    updateState((state) => state.copyWith(takenPhotoFile: photo));
  }

  /// Ключ озвучки текста под штрихкодом — по нему плеер узнаёт свой звук.
  String speechIdFor(String text) => ChatSpeaker.keyFor(text, _languageCode);

  void toggleSpeech(String text) =>
      _speaker.toggle(speechIdFor(text), text, _languageCode);

  void seekSpeech(Duration position) => _speaker.seek(position);

  Stream<Duration> get speechPositionStream => _speaker.positionStream;

  /// Умолкает — например, когда уходят в другой раздел.
  void stopSpeaking() => _speaker.stop();

  /// Камера поймала код.
  void onBarcode(String value, String languageCode) {
    _languageCode = languageCode;
    if (states.barcodeLookup == BarcodeLookup.searching) {
      _pendingBarcode = value;
      return;
    }
    _lookUp(value);
  }

  Future<void> _lookUp(String value) async {
    _speaker.stop();

    // QR со ссылкой или текстом искать в базе товаров бессмысленно — раньше
    // такой код получал «Товар не найден». Его надо просто прочитать.
    if (!isProductCode(value)) {
      _show(value, BarcodeLookup.text, value);
      _speak(value);
      return;
    }

    _show(value, BarcodeLookup.searching, null);
    try {
      final product = await _photoAnalysisRepository.getProduct(value);
      if (isClosed || states.barcode != value) return;
      final name = product?.nameFor(_languageCode);
      if (name == null) {
        _show(value, BarcodeLookup.notFound, Strings.commonProductNotFound);
        _speaker.announce(Strings.commonProductNotFound, _languageCode);
      } else {
        _show(value, BarcodeLookup.product, name);
        _speak(name);
      }
    } catch (error) {
      logger.w('Barcode lookup failed: $error');
      if (isClosed || states.barcode != value) return;
      // Раньше ошибка уходила только в лог, и пользователь слышал тишину.
      _show(value, BarcodeLookup.failed, Strings.messageConnectionError);
      _speaker.announce(Strings.messageConnectionError, _languageCode);
    } finally {
      final pending = _pendingBarcode;
      _pendingBarcode = null;
      if (!isClosed && pending != null && pending != value) _lookUp(pending);
    }
  }

  /// Второе нажатие на режим штрихкода: повторить, что нашлось.
  void repeatBarcode() {
    final text = states.barcodeText;
    if (text == null) return;
    if (states.barcodeLookup == BarcodeLookup.product ||
        states.barcodeLookup == BarcodeLookup.text) {
      _speak(text);
    } else {
      _speaker.announce(text, _languageCode);
    }
  }

  // ---------------------------------------------------------------- objects

  /// Предметы в очередном кадре — названия уже на языке приложения.
  void onObjectsInView(List<String> names, String languageCode) {
    _languageCode = languageCode;
    // Детектор отдаёт предметы то в одном порядке, то в другом. Если брать
    // его порядок, строка в карточке прыгала бы на каждом кадре, поэтому
    // кто уже в списке — остаётся на месте, новые встают в конец.
    final present = names.toSet();
    final previous = states.objectsInView;
    final stable = [
      ...previous.where(present.contains),
      ...present.where((name) => !previous.contains(name)),
    ];
    if (!listEquals(stable, previous)) {
      updateState((state) => state.copyWith(objectsInView: stable));
    }

    final fresh = _announcer.update(stable, DateTime.now());
    if (fresh.isEmpty) return;
    for (final name in fresh) {
      if (!_toAnnounce.contains(name)) _toAnnounce.add(name);
    }
    _announceTimer?.cancel();
    _announceTimer = Timer(announceAfter, _flushAnnouncements);
  }

  void _flushAnnouncements() {
    if (isClosed || _toAnnounce.isEmpty) return;
    _speaker.announce(_toAnnounce.join(', '), _languageCode);
    _toAnnounce.clear();
  }

  /// Перечень того, что сейчас в кадре, одной фразой.
  String get objectsSummary => states.objectsInView.join(', ');

  /// Что сказать, пока в кадре ничего не найдено. У «Предметов дома» —
  /// своя подсказка: навести камеру на комнату, а не на вещи вокруг.
  String get objectsHint => states.type == DashboardButtonType.homeObjects
      ? Strings.homeObjectsCameraHint
      : Strings.webObjectsCameraHint;

  /// Второе нажатие на режим объектов: назвать всё, что сейчас в кадре, —
  /// не только новое.
  void readObjectsInView() {
    _announceTimer?.cancel();
    _toAnnounce.clear();
    final summary = objectsSummary;
    if (summary.isEmpty) {
      _speaker.announce(objectsHint, _languageCode);
    } else {
      _speak(summary);
    }
  }

  void _resetObjects() {
    _announceTimer?.cancel();
    _toAnnounce.clear();
    _announcer.reset();
    if (states.objectsInView.isNotEmpty) {
      updateState((state) => state.copyWith(objectsInView: const []));
    }
  }

  // ------------------------------------------------------------ find object

  /// Говорит, когда искомое появилось в кадре. Ушло хотя бы на две секунды
  /// и вернулось — скажет снова: пользователь водит камерой и должен слышать,
  /// что снова навёлся.
  final ObjectAnnouncer _finder =
      ObjectAnnouncer(goneAfter: const Duration(seconds: 2));

  /// Когда искомое последний раз было в кадре. Карточка не гаснет на первом
  /// же кадре без него: детектор изредка теряет предмет на кадр-другой.
  DateTime? _lastFound;
  static const _foundHold = Duration(milliseconds: 800);

  /// Произнести служебную фразу тем же голосом, без плеера.
  void announce(String text, String languageCode) {
    _languageCode = languageCode;
    _speaker.announce(text, languageCode);
  }

  /// Начать искать [label] (имя из словаря детектора); [name] — оно же на
  /// языке приложения.
  void setFindTarget(String label, String name, String languageCode) {
    _languageCode = languageCode;
    _resetFind();
    updateState((state) => state.copyWith(
          findTarget: label,
          findTargetName: name,
        ));
    _speaker.announce(
      LocaleKeys.findObjectSearching.tr(args: [name]),
      languageCode,
    );
  }

  /// Очередной кадр в режиме поиска: есть ли в нём искомое.
  void onFindFrame(bool inView, String languageCode, {DateTime? now}) {
    final name = states.findTargetName;
    if (name == null) return;
    _languageCode = languageCode;
    now ??= DateTime.now();
    if (inView) _lastFound = now;

    if (_finder.update(inView ? [name] : const [], now).isNotEmpty) {
      _speaker.announce(name, languageCode);
    }

    final shown =
        _lastFound != null && now.difference(_lastFound!) < _foundHold;
    if (shown != states.findTargetInView) {
      updateState((state) => state.copyWith(findTargetInView: shown));
    }
  }

  void _resetFind() {
    _finder.reset();
    _lastFound = null;
    if (states.findTarget != null || states.findTargetInView) {
      updateState((state) => state.copyWith(
            findTarget: null,
            findTargetName: null,
            findTargetInView: false,
          ));
    }
  }

  void _speak(String text) =>
      _speaker.speak(speechIdFor(text), text, _languageCode);

  void _show(String barcode, BarcodeLookup lookup, String? text) {
    updateState((state) => state.copyWith(
          barcode: barcode,
          barcodeLookup: lookup,
          barcodeText: text,
        ));
  }

  void _resetBarcode() {
    _pendingBarcode = null;
    _speaker.stop();
    updateState((state) => state.copyWith(
          barcode: null,
          barcodeLookup: BarcodeLookup.waiting,
          barcodeText: null,
        ));
  }
}
