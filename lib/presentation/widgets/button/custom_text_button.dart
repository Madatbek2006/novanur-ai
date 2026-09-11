import 'package:flutter/material.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.textColor,
  }) : super(key: key);

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? textColor;

  bool isClickedRecently(DateTime? lastClickTime) {
    if (lastClickTime == null) return false;
    var now = DateTime.now();
    return (lastClickTime.difference(now).inMilliseconds) > -1000;
  }

  @override
  Widget build(BuildContext context) {
    DateTime? clickTime;

    final onButtonPressed = isEnabled
        ? () {
            if (isLoading) {
              return;
            } else if (isClickedRecently(clickTime)) {
              return;
            } else {
              clickTime = DateTime.now();
              onPressed?.call();
            }
          }
        : null;

    var defaultTextColor = Color(0xFF4393C7).withOpacity(isEnabled ? 1 : 0.75);
    return TextButton(
      onPressed: onButtonPressed,
      style: TextButton.styleFrom(
        textStyle: TextStyle(color: textColor ?? context.colors.buttonPrimary),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      child: Row(
        children: [
          text.w(500).s(14).c(textColor ?? (defaultTextColor)),
          Visibility(visible: isLoading, child: SizedBox(width: 12)),
          Visibility(
            visible: isLoading,
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: textColor ?? defaultTextColor,
                strokeWidth: 1.5,
                strokeAlign: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
