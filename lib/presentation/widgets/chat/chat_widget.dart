
import 'package:baiqavisit/presentation/widgets/chat/chat_text_field.dart';
import 'package:baiqavisit/presentation/widgets/message/image_message_widget.dart';
import 'package:baiqavisit/presentation/widgets/message/text_message_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChatWidget extends StatefulWidget {
  final String userUid;
  final List<types.AudioMessage> audioMessages;
  final List<types.Message> messages;
  final Function(String msg,) onSend;
  // final Function(String msg, types.Message? repliedMsg,List<XFile>? attachedFiles) onSendAudio;
  final Function(types.AudioMessage) onUpdateAudio;
  final Function() unSubRoom;
  final Function() subRoom;
  final bool isSendingRequest;

  const ChatWidget({
    super.key,
    required this.messages,
    required this.onSend,
    required this.userUid,
    required this.subRoom,
    required this.unSubRoom,
    required this.audioMessages,
    required this.isSendingRequest,
    required this.onUpdateAudio,
  });

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  List<XFile>? attachedFiles;


  final itemScrollController = ItemScrollController();
  final itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    widget.subRoom();
  }

  @override
  void dispose() {
    // widget.unSubRoom();
    super.dispose();
  }

  void scrollToMessage(types.Message message) {
    // final index = widget.messages.map((e)=>e.message).toList().indexOf(message);
    // if (index == -1) return;
    //
    // itemScrollController.scrollTo(
    //     index: index,
    //     duration: const Duration(milliseconds: 350),
    //     curve: Curves.easeInOut,
    //     alignment: 0.5
    // );
    //
    // setState(() => highlightedMessage = message);
    // Future.delayed(const Duration(seconds: 1), () {
    //   if (mounted) setState(() => highlightedMessage = null);
    // });
  }

  void _handleSend(types.PartialText p) {
    widget.onSend(p.text.trim());
    setState(() {
      attachedFiles = null;
    });
  }

  void _handleSendAudio(String path) {
    // widget.onSendAudio(path, repliedMessage,attachedFiles);
    // setState(() {
    //   repliedMessage = null;
    //   attachedFiles = null;
    // });
  }

  Widget buildMessage(types.Message message) {
    final isSentByMe = message.author.id == widget.userUid;

    // final alignment = isSentByMe ? Alignment.centerRight : Alignment.centerLeft;
    // final padding = EdgeInsets.only(
    //   left: isSentByMe ? 50 : 8,
    //   right: isSentByMe ? 8 : 50,
    // );
    Widget bubble;

    if (message is types.TextMessage) {
      bubble = TextMessageItem(
        isSentByMe: isSentByMe,
        message: message,
        messageWidth: 300,
        onClickRepliedMsg: (msg){
          scrollToMessage(msg);
        },
      );
    } else if (message is types.ImageMessage) {
      bubble = ImageMessageWidget(
        isSentByMe: isSentByMe,
        message: message,
        messageWidth: 300,
      );
    }
    // else if (message is types.AudioMessage) {
      // bubble = AudioMessageItem(
      //   isSentByMe: isSentByMe,
      //   audioMessage: item.message as types.AudioMessage,
      //   messageWidth: 260,
      //   onClickRepliedMsg: (msg){
      //     scrollToMessage(msg);
      //   },
      //   onUpdateAudio: widget.onUpdateAudio,
      // )
    // }
    else {
      bubble = const SizedBox.shrink();
    }

    return Row(
      children: [
        if (isSentByMe)
         Spacer(),
        bubble,
        if (!isSentByMe)
          Spacer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ScrollablePositionedList.builder(
            padding: EdgeInsets.only(bottom: 80,left: 16,right: 16),
            reverse: true,
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              final message = widget.messages[index];
              return KeyedSubtree(
                key: ValueKey(message.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // if (item.showDateHeader)
                    //   Center(
                    //     child: Container(
                    //       margin: const EdgeInsets.only(top: 12, bottom: 6),
                    //       padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    //       decoration: BoxDecoration(
                    //         color: Theme.of(context).brightness == Brightness.dark
                    //             ? Colors.white24
                    //             : Colors.black12,
                    //         borderRadius: BorderRadius.circular(12),
                    //       ),
                    //       child: Text(item.formattedDate,
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 13,
                    //             fontWeight: FontWeight.w500,
                    //           )),
                    //     ),
                    //   ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: buildMessage(message),
                    ),
                  ],
                ),
              );
            },
          ),

        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomInputField(
                isSendingRequest: widget.isSendingRequest,
                onSend: _handleSend,
                onSendAudio: _handleSendAudio,
                onAttached: (files) {
                  setState(() {
                    attachedFiles = files;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }



}
