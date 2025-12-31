import 'dart:ui';

import 'package:baiqavisit/presentation/widgets/card/custom_card.dart';
import 'package:flutter/material.dart';

class ProgressDialog {
  static void show(BuildContext context) {
    var isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child:  ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: isDarkMode? 10:0, sigmaY:   isDarkMode?10:0),
                child: CustomCard(
                  padding: EdgeInsets.all(24),
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 80,
                    width: 80,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

}