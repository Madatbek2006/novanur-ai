import 'package:flutter/material.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/support/theme/app_glass.dart';

class ProgressDialog {
  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Center(
          child: GlassSurface(
            width: 96,
            height: 96,
            blur: AppGlass.blurCard,
            borderRadius: AppGlass.cardAll,
            child: Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    dialogContext.primaryLight,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }
}
