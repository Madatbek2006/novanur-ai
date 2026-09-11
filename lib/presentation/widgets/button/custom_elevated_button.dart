import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double buttonWidth;
  final double buttonHeight;
  final bool isLoading;
  final bool isEnabled;
  final Color textColor;
  final double textSize;
  final Color? backgroundColor;
  final Widget? leftIcon;
  final Widget? rightIcon;

  const CustomElevatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.buttonWidth = double.infinity,
    this.buttonHeight = 52,
    this.isEnabled = true,
    this.isLoading = false,
    this.textColor = Colors.white,
    this.textSize = 15,
    this.backgroundColor,
    this.leftIcon,
    this.rightIcon,
  }) : super(key: key);

  bool isClickedRecently(DateTime? lastClickTime) {
    if (lastClickTime == null) return false;
    return (lastClickTime.difference(DateTime.now()).inMilliseconds) > -1000;
  }

  @override
  Widget build(BuildContext context) {
    DateTime? clickTime;

    final onButtonPressed = isEnabled && !isLoading
        ? () {
            if (isClickedRecently(clickTime)) return;
            clickTime = DateTime.now();
            onPressed?.call();
          }
        : null;

    final baseColor = backgroundColor ?? context.primaryLight;
    final effectiveColor = isEnabled ? baseColor : baseColor.withOpacity(0.5);
    final hasIcon = leftIcon != null || rightIcon != null;

    return GestureDetector(
      onTap: onButtonPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: buttonHeight,
        width: buttonWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(buttonHeight / 2),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              effectiveColor,
              effectiveColor.withOpacity(0.75),
            ],
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: effectiveColor.withOpacity(0.45),
                    blurRadius: 18,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasIcon && leftIcon != null) ...[
              SizedBox(width: 20, height: 20, child: leftIcon),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: text
                  .w(600)
                  .s(textSize)
                  .c(isEnabled ? textColor : textColor.withOpacity(0.6))
                  .copyWith(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
            ),
            if (isLoading) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ] else if (hasIcon && rightIcon != null) ...[
              const SizedBox(width: 8),
              SizedBox(width: 20, height: 20, child: rightIcon),
            ],
          ],
        ),
      ),
    );
  }
}
