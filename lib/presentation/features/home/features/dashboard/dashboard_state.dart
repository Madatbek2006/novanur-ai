part of 'dashboard_cubit.dart';

/// Что сейчас со штрихкодом в кадре.
enum BarcodeLookup {
  /// Код ещё не попадался.
  waiting,

  /// Код пойман, ищем товар.
  searching,

  /// Нашли товар — [DashboardState.barcodeText] это его название.
  product,

  /// Код не товарный (QR со ссылкой или текстом) — читаем его как есть.
  text,

  /// Такого товара в базе нет.
  notFound,

  /// Не достучались до базы.
  failed,
}

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState({
    DashboardButtonType? type,
    XFile? takenPhotoFile,
    /// Последний пойманный код и что с ним.
    String? barcode,
    @Default(BarcodeLookup.waiting) BarcodeLookup barcodeLookup,
    /// Что показать и прочитать: название товара или текст кода.
    String? barcodeText,
    /// Предметы в кадре — уже на языке приложения, без повторов.
    @Default(<String>[]) List<String> objectsInView,
    /// Что ищем: имя из словаря детектора, по-английски, как он отвечает.
    String? findTarget,
    /// То же на языке приложения — так оно показывается и звучит.
    String? findTargetName,
    /// Искомое сейчас в кадре.
    @Default(false) bool findTargetInView,
    /// Озвучка — тот же плеер, что в чате и остальных разделах.
    SpeechPlayback? playback,
    @Default(<String, SpeechPlayback>{}) Map<String, SpeechPlayback> speechClips,
  }) = _DashboardState;
}

@freezed
class DashboardEvent with _$DashboardEvent {
  const factory DashboardEvent(DashboardEventType type) = _DashboardEvent;
}

enum DashboardEventType { onShowTakenPhoto, openResultScreen }
