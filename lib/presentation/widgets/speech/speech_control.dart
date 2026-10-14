import 'package:flutter/material.dart';
import 'package:nurnova_ai/domain/models/chat/speech_playback.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/widgets/message/speech_player_bar.dart';

/// Плеер озвучки для любого раздела — та же полоса, что под ответом в чате:
/// кнопка, огибающая, часы и перемотка.
///
/// Спикер в разделе один, а текстов, которые он читал, может быть несколько,
/// поэтому полоса сама разбирается, звучит ли сейчас именно её текст. Если
/// нет — показывает то, что о нём уже известно, и стоит на нуле, а не
/// повторяет чужой отсчёт.
class SpeechControl extends StatelessWidget {
  const SpeechControl({
    super.key,
    required this.speechId,
    required this.playback,
    required this.clips,
    required this.positionStream,
    required this.onToggle,
    required this.onSeek,
    this.color,
  });

  /// Ключ озвучки этого текста — см. ChatSpeaker.keyFor.
  final String speechId;

  /// Что сейчас звучит в разделе. Может относиться к другому тексту.
  final SpeechPlayback? playback;

  /// Уже озвученные тексты раздела.
  final Map<String, SpeechPlayback> clips;

  final Stream<Duration> positionStream;
  final VoidCallback onToggle;
  final ValueChanged<Duration> onSeek;

  /// Цвет кнопки и столбиков. По умолчанию — цвет основного текста.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isCurrent = playback?.messageId == speechId;

    return LayoutBuilder(
      builder: (context, constraints) => SpeechPlayerBar(
        playback: isCurrent
            ? playback!
            : clips[speechId] ??
                SpeechPlayback(messageId: speechId, status: SpeechStatus.idle),
        positionStream:
            isCurrent ? positionStream : const Stream<Duration>.empty(),
        onToggle: onToggle,
        onSeek: onSeek,
        color: color ?? context.textPrimary,
        maxWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : 360,
      ),
    );
  }
}
