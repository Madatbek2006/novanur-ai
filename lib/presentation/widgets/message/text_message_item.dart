import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:baiqavisit/presentation/widgets/card/custom_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

class TextMessageItem extends StatelessWidget{
  final bool isSentByMe;
  final TextMessage message;
  final int messageWidth;
  final Function(Message message)onClickRepliedMsg;

  const TextMessageItem({super.key, required this.isSentByMe, required this.message, required this.messageWidth, required this.onClickRepliedMsg});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if(isSentByMe)
          SizedBox(
            width: 50,
          ),
        CustomCard(
          padding: EdgeInsets.only(
              left: 8,
              right: 8,
              top: 8,
              bottom: 2
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(isSentByMe?8:0),
            bottomRight: Radius.circular(isSentByMe?0:8),
          ),
          color: isSentByMe?context.primaryLight:context.borderStroke,
          child: IntrinsicWidth(
            stepWidth: 1,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // if(message.repliedMessage!=null)
                //   RepledMessage(
                //     message: message.repliedMessage!,
                //     messageWidth: messageWidth.toDouble(),
                //     onClickRepliedMsg: onClickRepliedMsg,
                //   ),
                // if(message.metadata?[MsgMetadata.discuss.name]!=null)
                // DiscussMessageWidget(
                //   discuss: message.metadata?[MsgMetadata.discuss.name],
                //   messageMaxWidth: messageWidth.toDouble(),
                //   isSentByMe: isSentByMe,
                // ),
                //
                // if(message.metadata?[MsgMetadata.attachedUrl.name]!=null||message.metadata?[MsgMetadata.attachedFile.name]!=null)
                //   AttachedFileGridWidget(
                //     size: messageWidth.toDouble(),
                //     urls: message.metadata?[MsgMetadata.attachedUrl.name],
                //     files: message.metadata?[MsgMetadata.attachedFile.name],
                //   ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if(message.text!="voiceUYjmmsK<KsdnbDgks")
                    Container(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      constraints: BoxConstraints(maxWidth: messageWidth.toDouble()-111.335), // ограничение по ширине
                      child: message.text
                          .s(14)
                          .w(600)
                          .c(isSentByMe ? context.mainBg : context.textPrimary),
                    ),
                    // message.text.s(14).w(600).c(isSentByMe?context.mainBg:context.textPrimary),
                    SizedBox(height: 8),
                    SizedBox(
                      width: 4,
                    ),
                    if(message.createdAt!=null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(message.createdAt!).toLocal()).s(10).w(500).c(isSentByMe?context.mainBg:context.textPrimary),
                          // if(isSentByMe)
                          //   message.status==Status.seen?
                          //   Assets.images.component.icCheckAll.svgCustom(
                          //     height: 16,
                          //     width: 16,
                          //     color: context.mainBg,
                          //   ):Assets.images.component.icCheck.svgCustom(
                          //     height: 16,
                          //     width: 16,
                          //     color: context.mainBg,
                          //   )
                        ],
                      )

                  ],
                ),
              ],
            ),
          ),
        ),
        if(!isSentByMe)
          SizedBox(
            width: 50,
          ),
      ],
    );
  }


}
