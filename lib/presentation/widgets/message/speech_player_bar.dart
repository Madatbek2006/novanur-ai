import 'dart:math' as math;

import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/domain/models/chat/speech_playback.dart';
import 'package:flutter/material.dart';

/// Плеер под текстом ответа.
///
/// Показывает ровно то, что о звуке известно. Когда звук — файл с сервера,
/// это кнопка, столбики огибающей, прошедшее время и перемотка. Когда читает
/// движок телефона, файла нет: ни длительности, ни позиции не существует,
/// поэтому остаётся одна кнопка — честнее, чем рисовать мёртвую полосу.
class SpeechPlayerBar extends StatelessWidget {
  const SpeechPlayerBar({
    super.key,
    required this.playback,
    required this.positionStream,
    required this.onToggle,
    required this.onSeek,
    required this.color,
    required this.maxWidth,
  });

  /// Высота строки плеера. Её закладывают в расчёт высоты пузыря.
  static const double height = 36;

  static const double _buttonSize = 32;
  static const double _minWidth = 220;

  final SpeechPlayback playback;
  final Stream<Duration> positionStream;
  final VoidCallback onToggle;
  final ValueChanged<Duration> onSeek;

  /// Цвет текста пузыря: плеер подстраивается под него, а не под тему.
  final Color color;

  /// Сколько места отвёл пузырь. Плеер никогда не выходит за эту границу.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final loading = playback.status == SpeechStatus.loading;
    final playing = playback.status == SpeechStatus.playing;

    return ConstrainedBox(
      constraints: BoxConstraints(
        // Узкий ответ не должен сжимать плеер до нечитаемого огрызка,
        // но и вылезать за пузырь ему нельзя.
        minWidth: math.min(_minWidth, maxWidth),
        maxWidth: maxWidth,
      ),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            _button(loading: loading, playing: playing),
            if (playback.seekable) ...[
              const SizedBox(width: 10),
              Expanded(child: _progress(loading: loading)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _button({required bool loading, required bool playing}) {
    return Semantics(
      button: true,
      label: loading
          ? Strings.chatSpeechLoading
          : playing
              ? Strings.chatSpeechPause
              : Strings.chatSpeechPlay,
      child: GestureDetector(
        onTap: onToggle,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: _buttonSize,
          height: _buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
          ),
          alignment: Alignment.center,
          child: loading
              // Круг ожидания на месте кнопки: нажатие остаётся живым и
              // отменяет синтез, поэтому кнопка не подменяется индикатором,
              // а надевает его на себя.
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              : Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 20,
                  color: color,
                ),
        ),
      ),
    );
  }

  /// Столбики и время. Подписан на позицию отдельно от всего остального,
  /// чтобы тик позиции перерисовывал только эту часть, а не список сообщений.
  Widget _progress({required bool loading}) {
    if (loading) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          Strings.chatSpeechLoading,
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
        ),
      );
    }

    return StreamBuilder<Duration>(
      stream: positionStream,
      initialData: Duration.zero,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final total = playback.duration;
        final progress = total > Duration.zero
            ? (position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;

        return Row(
          children: [
            Expanded(child: _waveform(progress, total)),
            const SizedBox(width: 8),
            Text(
              _clock(position),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _waveform(double progress, Duration total) {
    return Semantics(
      // Скринридер объявит это ползунком и даст менять значение свайпами:
      // тащить пальцем по узкой полоске вслепую невозможно.
      slider: true,
      label: Strings.chatSpeechPosition,
      value: '${(progress * 100).round()}%',
      child: LayoutBuilder(
        builder: (context, constraints) {
          void seekTo(double dx) {
            if (total <= Duration.zero || constraints.maxWidth <= 0) return;
            final ratio = (dx / constraints.maxWidth).clamp(0.0, 1.0);
            onSeek(total * ratio);
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => seekTo(details.localPosition.dx),
            onHorizontalDragUpdate: (details) =>
                seekTo(details.localPosition.dx),
            child: CustomPaint(
              size: Size(constraints.maxWidth, 20),
              painter: _WaveformPainter(
                peaks: playback.peaks,
                progress: progress,
                color: color,
              ),
            ),
          );
        },
      ),
    );
  }

  static String _clock(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.peaks,
    required this.progress,
    required this.color,
  });

  final List<double> peaks;
  final double progress;
  final Color color;

  static const double _barWidth = 2;
  static const double _gap = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final played = Paint()..color = color.withOpacity(0.9);
    final rest = Paint()..color = color.withOpacity(0.3);

    // Огибающей может не быть — например, звук пришёл в незнакомом формате.
    // Тогда вместо столбиков рисуем обычную полосу: перемотка от этого
    // не страдает.
    if (peaks.isEmpty) {
      const double track = 3;
      final top = (size.height - track) / 2;
      final radius = Radius.circular(track / 2);
      canvas.drawRRect(
        RRect.fromLTRBR(0, top, size.width, top + track, radius),
        rest,
      );
      canvas.drawRRect(
        RRect.fromLTRBR(0, top, size.width * progress, top + track, radius),
        played,
      );
      return;
    }

    final slot = _barWidth + _gap;
    final fits = math.max(1, (size.width / slot).floor());
    final step = peaks.length / fits;
    final edge = size.width * progress;

    for (var i = 0; i < fits; i++) {
      final peak = peaks[math.min((i * step).floor(), peaks.length - 1)];
      // Совсем нулевых столбиков не рисуем: пауза в речи должна читаться
      // как тонкая линия, а не как дыра.
      final barHeight = math.max(2.0, peak * size.height);
      final left = i * slot;
      final top = (size.height - barHeight) / 2;

      canvas.drawRRect(
        RRect.fromLTRBR(
          left,
          top,
          left + _barWidth,
          top + barHeight,
          const Radius.circular(1),
        ),
        left + _barWidth <= edge ? played : rest,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.progress != progress ||
      old.color != color ||
      !identical(old.peaks, peaks);
}
