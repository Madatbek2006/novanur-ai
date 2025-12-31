import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:baiqavisit/presentation/widgets/card/custom_card.dart';
import 'package:baiqavisit/presentation/widgets/message/attached_file_grid_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

class ImageMessageWidget extends StatelessWidget {
  final bool isSentByMe;
  final ImageMessage message;
  final int messageWidth;

  const ImageMessageWidget(
      {super.key,
      required this.isSentByMe,
      required this.message,
      required this.messageWidth});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (isSentByMe)
        SizedBox(
          width: 50,
        ),
      CustomCard(
          padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(isSentByMe ? 8 : 0),
            bottomRight: Radius.circular(isSentByMe ? 0 : 8),
          ),
          color: isSentByMe ? context.primaryLight : context.borderStroke,
          child: IntrinsicWidth(stepWidth: 1, child: AttachedFileGridWidget(
            files: [message.uri],
            size: messageWidth.toDouble(),
          )
          )
      )
    ]
    );
  }
}
