import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/domain/models/chat/speech_playback.dart';
import 'package:nurnova_ai/presentation/widgets/card/custom_card.dart';
import 'package:nurnova_ai/presentation/widgets/chat/chat_text_field.dart';
import 'package:nurnova_ai/presentation/widgets/message/image_message_widget.dart';
import 'package:nurnova_ai/presentation/widgets/message/text_message_item.dart';
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

  /// Space kept clear at the top so the first messages are not hidden by a
  /// translucent app bar that the list scrolls underneath.
  final double topInset;

  /// Что сейчас с озвучкой: какое сообщение, на какой стадии и перематывается
  /// ли оно. Плеер рисуется у того сообщения, чей id здесь.
  final SpeechPlayback? playback;

  /// Позиция воспроизведения отдельным потоком: её тики перерисовывают
  /// только полоску плеера, а не список сообщений.
  final Stream<Duration>? positionStream;

  /// Нажатие на ответ ассистента — переключает чтение вслух.
  final Function(types.TextMessage)? onMessageTap;

  /// Перемотка внутри ответа.
  final ValueChanged<Duration>? onSeek;

  /// Текст ошибки. Пока он есть, над полем ввода висит полоса с повтором.
  final String? errorText;
  final VoidCallback? onRetry;

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
    this.topInset = 0,
    this.playback,
    this.positionStream,
    this.onMessageTap,
    this.onSeek,
    this.errorText,
    this.onRetry,
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

  /// Горизонтальный паддинг списка сообщений.
  static const double listHorizontalPadding = 16;

  Widget buildMessage(types.Message message) {
    final isSentByMe = message.author.id == widget.userUid;

    // final alignment = isSentByMe ? Alignment.centerRight : Alignment.centerLeft;
    // final padding = EdgeInsets.only(
    //   left: isSentByMe ? 50 : 8,
    //   right: isSentByMe ? 8 : 50,
    // );
    Widget bubble;

    // messageWidth — это ширина СОДЕРЖИМОГО, а пузырь занимает ещё и обвязку:
    // отступ с дальней стороны плюс паддинг карточки. У текста она 40+12*2=64,
    // у картинки 40+5*2=50, поэтому одно общее число неизбежно врёт для одного
    // из типов (раньше вычиталось 50, и текстовый пузырь вылезал ровно на 14).
    // Считаем по константам самих виджетов, чтобы значения не разъезжались.
    final rowWidth =
        MediaQuery.sizeOf(context).width - listHorizontalPadding * 2;
    double contentWidth(double chrome) =>
        (rowWidth - chrome).clamp(160.0, 320.0).toDouble();

    if (message is types.TextMessage) {
      bubble = TextMessageItem(
        isSentByMe: isSentByMe,
        message: message,
        messageWidth: contentWidth(TextMessageItem.chrome).round(),
        // Плеер принадлежит только тому сообщению, которое сейчас звучит;
        // у остальных он в покое и показывает одну кнопку.
        playback: widget.playback?.messageId == message.id
            ? widget.playback
            : null,
        positionStream: widget.positionStream,
        // Ответы читаются вслух, свои сообщения — нет.
        onTap: isSentByMe ? null : () => widget.onMessageTap?.call(message),
        onSeek: widget.onSeek,
        onClickRepliedMsg: (msg) {
          scrollToMessage(msg);
        },
      );
    } else if (message is types.ImageMessage) {
      bubble = ImageMessageWidget(
        isSentByMe: isSentByMe,
        message: message,
        messageWidth: contentWidth(ImageMessageWidget.chrome).round(),
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
    // The composer used to float in a Stack while the list guessed its height
    // with a hardcoded `bottom: 80`. A Column gives the list exactly the room
    // that is left, so nothing hides behind the bar and no magic number drifts.
    return Column(
      children: [
        Expanded(
          child: ScrollablePositionedList.builder(
            padding: EdgeInsets.fromLTRB(
                listHorizontalPadding,
                widget.topInset + 8,
                listHorizontalPadding,
                8,
              ),
            reverse: true,
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
            itemCount:
                widget.messages.length + (widget.isSendingRequest ? 1 : 0),
            itemBuilder: (context, index) {
              if (widget.isSendingRequest && index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: loadingBubble(),
                );
              }

              final realIndex = widget.isSendingRequest ? index - 1 : index;

              final message = widget.messages[realIndex];

              return KeyedSubtree(
                key: ValueKey(message.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: buildMessage(message),
                ),
              );
            },
          ),
        ),
        if (widget.errorText != null) _errorBar(context, widget.errorText!),
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
    );
  }

  /// Полоса с ошибкой и кнопкой повтора. Текст ошибки ещё и проговаривается
  /// вслух — на экран здесь смотрят не все.
  Widget _errorBar(BuildContext context, String text) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        listHorizontalPadding,
        0,
        listHorizontalPadding,
        8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 20, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: scheme.onErrorContainer),
            ),
          ),
          if (widget.onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: widget.onRetry,
              child: Text(Strings.chatErrorRetry),
            ),
          ],
        ],
      ),
    );
  }

  Widget loadingBubble() {
    return Row(
      children: [
        CustomCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(8),
          ),
          child: const SizedBox(
            width: 26,
            height: 18,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TypingDots(),
            ),
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
          style: const TextStyle(fontSize: 18, height: 1),
        );
      },
    );
  }
}
