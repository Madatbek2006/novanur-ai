import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/support/theme/app_glass.dart';
import 'package:nurnova_ai/presentation/widgets/dialog/speech_to_text_dialog.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';

/// Height of the input pill and the send button. Everything else in the
/// composer is derived from it, so the bar stays compact.
const double _fieldHeight = 44;

class CustomInputField extends StatefulWidget {
  const CustomInputField({
    super.key,
    required this.onSend,
    required this.onSendAudio,
    required this.onAttached,
    required this.isSendingRequest,
    this.blurQuality = AppGlass.blurPanel,
    this.borderRadius,
  });

  final void Function(PartialText) onSend;
  final void Function(String audioPath) onSendAudio;
  final void Function(List<XFile>) onAttached;
  final bool isSendingRequest;
  final double blurQuality;
  final BorderRadius? borderRadius;

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  StreamSubscription? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    widget.onSend(PartialText(text: text));
    _controller.clear();
    if (focusNode.hasFocus) FocusScope.of(context).unfocus();
  }

  void _dictate() {
    HapticFeedback.lightImpact();
    showDialog<void>(
      context: context,
      useRootNavigator: false,
      builder: (_) => GoogleSpeechDialog(
        onResult: (text) {
          if (text.trim().isEmpty) return;
          widget.onSend(PartialText(text: text.trim()));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      blur: widget.blurQuality,
      borderRadius: widget.borderRadius ?? AppGlass.sheet,
      edge: GlassEdge.top,
      hasShadow: false,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: GlassSurface(
                blur: AppGlass.blurChip,
                borderRadius: BorderRadius.circular(AppGlass.radiusPill),
                hasShadow: false,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                // No Center / ConstrainedBox here on purpose: Center expands to
                // the tallest size it is allowed, so wrapping the field made the
                // pill exactly maxHeight tall no matter what was typed. The
                // field sizes itself from contentPadding and grows with maxLines.
                child: TextField(
                  focusNode: focusNode,
                  controller: _controller,
                  enabled: !widget.isSendingRequest,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 15,
                    height: 1.25,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: Strings.chatMessageHint,
                    hintStyle: TextStyle(
                      color: context.textPrimary.withOpacity(0.45),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (!widget.isSendingRequest)
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) {
                  final isEmpty = value.text.trim().isEmpty;

                  return _SendButton(
                    icon: isEmpty ? Icons.mic_rounded : Icons.send_rounded,
                    onTap: isEmpty ? _dictate : _send,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.primaryLight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: _fieldHeight,
        height: _fieldHeight,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent, accent.withOpacity(0.72)],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: AppGlass.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.38),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
