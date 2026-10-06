import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/widgets/card/custom_card.dart';
import 'package:nurnova_ai/presentation/widgets/message/attached_file_grid_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

class ImageMessageWidget extends StatelessWidget {
  /// Пустой отступ с дальней стороны пузыря.
  static const double gutter = 40;

  /// Паддинг карточки (с каждой стороны).
  static const double cardPadding = 5;

  /// Сколько места пузырь занимает сверх самой картинки.
  static const double chrome = gutter + cardPadding * 2;

  final bool isSentByMe;
  final ImageMessage message;
  final int messageWidth;

  const ImageMessageWidget({
    super.key,
    required this.isSentByMe,
    required this.message,
    required this.messageWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSentByMe) const SizedBox(width: gutter),
        CustomCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(cardPadding),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10),
            bottomLeft: Radius.circular(isSentByMe ? 10 : 0),
            bottomRight: Radius.circular(isSentByMe ? 0 : 10),
          ),
          color: isSentByMe ? context.primaryLight : context.borderStroke,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AttachedFileGridWidget(
              files: [message.uri],
              size: messageWidth.toDouble(),
            ),
          ),
        ),
        if (!isSentByMe) const SizedBox(width: gutter),
      ],
    );
  }
}
