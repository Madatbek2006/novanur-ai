import 'package:baiqavisit/presentation/widgets/card/custom_card.dart';
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
  final Function(
    String msg,
  ) onSend;

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
        onClickRepliedMsg: (msg) {
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
        if (isSentByMe) Spacer(),
        bubble,
        if (!isSentByMe) Spacer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ScrollablePositionedList.builder(
            padding: EdgeInsets.only(bottom: 80, left: 16, right: 16),
            reverse: true,
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
            itemCount:
                widget.messages.length + (widget.isSendingRequest ? 1 : 0),
            itemBuilder: (context, index) {
              if (widget.isSendingRequest && index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: loadingBubble(),
                );
              }

              final realIndex = widget.isSendingRequest ? index - 1 : index;

              final message = widget.messages[realIndex];

              return KeyedSubtree(
                key: ValueKey(message.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: buildMessage(message),
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

  Widget loadingBubble() {
    return Row(
      children: [
        CustomCard(
          padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular( 0),
            bottomRight: Radius.circular(8),
          ),
          child: SizedBox(
            width: 32,
              child: Align(
                alignment: Alignment.centerLeft,
                  child: TypingDots()
              )
          ),
        ),

        const Spacer(),
      ],
    );
  }
}

class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final value = (_controller.value * 3).floor() + 1;
        return Text(
          '.' * value,
          style: const TextStyle(fontSize: 24),
        );
      },
    );
  }
}
