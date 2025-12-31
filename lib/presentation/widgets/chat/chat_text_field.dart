import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:baiqavisit/presentation/widgets/card/custom_card.dart';
import 'package:baiqavisit/utils/service/photo_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CustomInputField extends StatefulWidget {
  final void Function(PartialText) onSend;
  final void Function(String audioPath) onSendAudio;
  final void Function(List<XFile>) onAttached;
  final bool isSendingRequest;
  final double blurQuality;
  final BorderRadius? borderRadius;

  const CustomInputField({
    required this.onSend,
    required this.onSendAudio,
    required this.isSendingRequest,
    required this.onAttached,
    this.blurQuality = 30,
    this.borderRadius,

  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  double _micScale = 1.0;
  bool _isRecording = false;

  Duration _recordTime = Duration.zero;
  late StreamSubscription _sub;

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void initState() {
    super.initState();

    // _sub = AudioRecorderService.onProgress.listen((d) {
    //   setState(() => _recordTime = d);
    // });
    //
    // AudioRecorderService.init();
  }

  @override
  void dispose() {
    _sub.cancel();
    _controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {

  }

  Future<void> _stopRecording() async {
    // if (!_isRecording) return;
    //
    // final path = await AudioRecorderService.stop();
    //
    // setState(() {
    //   _isRecording = false;
    //   _micScale = 1.0;
    // });
    //
    // if (path == null) return;
    //
    // if (_recordTime < Duration(seconds: 1)) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Удерживай дольше для записи")),
    //   );
    //   File(path).delete();
    //   return;
    // }
    //
    // widget.onSendAudio(path);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ??
          BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurQuality,
          sigmaY: widget.blurQuality,
        ),
        child: CustomCard(
          color: context.borderStroke.withValues(alpha: 0.5),
          borderRadius: widget.borderRadius ??
              BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: CustomCard(
                  height: 56,
                  color: context.mainBg,
                  borderRadius: BorderRadius.circular(28),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _isRecording
                      ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedOpacity(
                          opacity: DateTime.now().millisecond % 1000 < 500 ? 1 : 0.3,
                          duration: Duration(milliseconds: 500),
                          child: Icon(Icons.mic, color: Colors.red, size: 28),
                        ),
                        SizedBox(width: 8),
                        Text(
                          _format(_recordTime),
                          style: TextStyle(
                            color: context.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                      : Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: focusNode,
                          maxLines: 5,
                          minLines: 1,
                          enabled: !widget.isSendingRequest,
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: "Сообщение...",
                            border: InputBorder.none,
                          ),
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                      SizedBox(width: 16),
                      IconButton(
                        icon: Icon(Icons.attach_file, color: context.iconPrimary),
                        onPressed: () async {
                          var files=await PhotoPickerService.pickMultipleFromGallery(context);
                          if(files!=null){
                            widget.onAttached(files);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16),
              if (!widget.isSendingRequest)
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, child) {
                    final empty = value.text.isEmpty;
                    return empty?
                    GestureDetector(
                      onLongPressStart:  (_) => _startRecording(),
                      onLongPressEnd: (_) => _stopRecording() ,
                      child: AnimatedScale(
                        scale: empty ? _micScale : 1,
                        duration: Duration(milliseconds: 150),
                        child: CustomCard(
                          borderRadius: BorderRadius.circular(28),
                          color: context.primaryLight,
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.mic,
                            color: context.mainBg,
                          ),
                        ),
                      ),
                    ):InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: (){
                        if(_controller.text.trim().isNotEmpty) {
                          widget.onSend(PartialText(text: _controller.text.trim()));
                        }
                        _controller.clear();
                        if(focusNode.hasFocus){
                          FocusScope.of(context).unfocus();
                        }
                      },
                      child: CustomCard(
                        borderRadius: BorderRadius.circular(28),
                        color: context.primaryLight,
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.send,
                          color: context.mainBg,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

