import 'package:flutter/foundation.dart';

/// Что происходит с озвучкой прямо сейчас.
enum SpeechStatus {
  /// Сервер ещё синтезирует звук: играть нечего, но сообщение уже выбрано.
  loading,
  playing,
  paused,

  /// Звук готов и лежит рядом, но сейчас молчит — дослушали до конца или
  /// зазвучал другой ответ. Полосу в этом состоянии убирать нельзя:
  /// огибающая и длительность уже посчитаны, а переслушать длинное
  /// описание без перемотки невозможно.
  idle,
}

/// Состояние озвучки одного сообщения — то, что нужно знать экрану.
///
/// Позиции воспроизведения здесь намеренно нет. Она меняется десятки раз в
/// секунду, а состояние чата сравнивается целиком (см. BaseBuilder.buildWhen),
/// так что каждый тик перерисовывал бы весь список сообщений. Позицию отдаёт
/// отдельный поток, на который подписывается только сама полоска плеера.
@immutable
class SpeechPlayback {
  const SpeechPlayback({
    required this.messageId,
    required this.status,
    this.seekable = false,
    this.duration = Duration.zero,
    this.peaks = const <double>[],
  });

  final String messageId;
  final SpeechStatus status;

  /// Перемотка возможна, только когда звук — это файл. Движок телефона
  /// говорит прямо в динамик: ни длительности, ни позиции у него нет,
  /// поэтому для него рисуется одна кнопка без полосы.
  final bool seekable;

  final Duration duration;

  /// Огибающая звука, 0..1, для столбиков как в мессенджерах.
  /// Пустая, если звук не файл или формат разобрать не удалось.
  final List<double> peaks;

  SpeechPlayback copyWith({
    SpeechStatus? status,
    bool? seekable,
    Duration? duration,
    List<double>? peaks,
  }) {
    return SpeechPlayback(
      messageId: messageId,
      status: status ?? this.status,
      seekable: seekable ?? this.seekable,
      duration: duration ?? this.duration,
      peaks: peaks ?? this.peaks,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SpeechPlayback &&
        other.messageId == messageId &&
        other.status == status &&
        other.seekable == seekable &&
        other.duration == duration &&
        listEquals(other.peaks, peaks);
  }

  @override
  int get hashCode =>
      Object.hash(messageId, status, seekable, duration, peaks.length);
}
