import 'package:baiqavisit/presentation/support/colors/static_colors.dart';
import 'package:flutter/material.dart';

class DefaultLoadingWidget extends StatelessWidget {
  const DefaultLoadingWidget({super.key, required this.isFullScreen});

  final bool isFullScreen;

  @override
  Widget build(BuildContext context) {
    return isFullScreen
        ? Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.grey[300],
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                StaticColors.buttonColor,
              ),
            ),
          )
        : SizedBox(
            height: 160,
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.grey[300],
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  StaticColors.buttonColor,
                ),
              ),
            ),
          );
  }
}
