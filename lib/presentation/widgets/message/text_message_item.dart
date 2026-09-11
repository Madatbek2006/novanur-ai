import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/widgets/card/custom_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

/// Placeholder text used by the audio path to mark a non-text payload.
const _voiceSentinel = "voiceUYjmmsK<KsdnbDgks";

class TextMessageItem extends StatelessWidget {
  /// Пустой отступ с дальней стороны пузыря.
  static const double gutter = 40;

  /// Горизонтальный паддинг карточки (с каждой стороны).
  static const double cardHorizontalPadding = 12;

  /// Сколько места пузырь занимает сверх самого текста.
  static const double chrome = gutter + cardHorizontalPadding * 2;

  final bool isSentByMe;
  final TextMessage message;
  final int messageWidth;
  final Function(Message message) onClickRepliedMsg;

  /// Сообщение читается вслух прямо сейчас.
  final bool isSpeaking;

  /// Нажатие по пузырю: повторить чтение или остановить его.
  /// null — если сообщение не озвучивается (свои реплики).
  final VoidCallback? onTap;

  const TextMessageItem({
    super.key,
    required this.isSentByMe,
    required this.message,
    required this.messageWidth,
    required this.onClickRepliedMsg,
    this.isSpeaking = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onBubble = isSentByMe ? context.mainBg : context.textPrimary;

    final bubble = CustomCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(
            horizontal: cardHorizontalPadding,
            vertical: 7,
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
            bottomLeft: Radius.circular(isSentByMe ? 8 : 0),
            bottomRight: Radius.circular(isSentByMe ? 0 : 8),
          ),
          color: isSentByMe ? context.primaryLight : context.borderStroke,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: messageWidth.toDouble()),
            // Timestamp rides on the last line's baseline instead of taking a
            // row of its own — that alone was costing every bubble ~16px.
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (message.text != _voiceSentinel)
                  Flexible(
                    child: message.text.s(14).w(500).h(1.3).c(onBubble),
                  ),
                if (message.createdAt != null) ...[
                  const SizedBox(width: 8),
                  DateFormat('HH:mm')
                      .format(
                        DateTime.fromMillisecondsSinceEpoch(message.createdAt!)
                            .toLocal(),
                      )
                      .s(10)
                      .w(500)
                      .c(onBubble.withOpacity(0.7)),
                ],
                if (onTap != null) ...[
                  const SizedBox(width: 6),
                  Icon(
                    isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                    size: 16,
                    color: onBubble.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ),
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSentByMe) const SizedBox(width: gutter),
        if (onTap == null)
          bubble
        else
          // Весь пузырь — одна большая кнопка: попасть в неё легко и вслепую,
          // а скринридер объявит, что именно произойдёт по нажатию.
          Semantics(
            button: true,
            label: isSpeaking
                ? Strings.chatStopSpeaking
                : Strings.chatRepeatAnswer,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: bubble,
            ),
          ),
        if (!isSentByMe) const SizedBox(width: gutter),
      ],
    );
  }
}
