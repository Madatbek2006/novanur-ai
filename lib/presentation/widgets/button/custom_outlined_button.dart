import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double buttonWidth;
  final double buttonHeight;
  final bool isLoading;
  final bool isEnabled;
  final bool isSelected;
  final Color? textColor;
  final Color? strokeColor;
  final Widget? rightIcon;

  const CustomOutlinedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.buttonWidth = double.infinity,
    this.buttonHeight = 48,
    this.isEnabled = true,
    this.isLoading = false,
    this.isSelected = false,
    this.textColor,
    this.strokeColor,
    this.rightIcon,
  }) : super(key: key);

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
              onPressed.call();
            }
          }
        : null;

    var stroke = strokeColor ?? context.outlinedButtonStroke;
    var actualStrokeColor = isEnabled ? stroke : stroke.withOpacity(0.55);

    final textColor1 = textColor ?? actualStrokeColor;
    var actualTextColor = isEnabled ? textColor1 : textColor1.withOpacity(0.75);

    var actualTextAlign = rightIcon != null ? TextAlign.left : TextAlign.center;

    return OutlinedButton(
      onPressed: onButtonPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: context.outlinedButtonBackground,
        foregroundColor: context.outlinedButtonBackground.withOpacity(0.45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(
          width: isSelected ? 1.5 : 1,
          color: actualStrokeColor,
        ),
      ),
      child: SizedBox(
        width: buttonWidth,
        height: buttonHeight,
        child: Row(
          children: [
            Visibility(
              visible: isLoading,
              child: SizedBox(
                width: 24,
                height: 20,
              ),
            ),
            Expanded(
              child: text.w(400).s(13).c(actualTextColor).copyWith(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: actualTextAlign,
                  ),
            ),
            Visibility(visible: isLoading, child: SizedBox(width: 4)),
            Visibility(
              visible: isLoading,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: actualStrokeColor,
                  strokeWidth: 1.5,
                  strokeAlign: 0.5,
                ),
              ),
            ),
            Visibility(visible: rightIcon != null, child: SizedBox(width: 4)),
            Visibility(
              visible: rightIcon != null,
              child: SizedBox(width: 24, height: 24, child: rightIcon),
            ),
          ],
        ),
      ),
    );
  }
}
