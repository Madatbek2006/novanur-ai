import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class BottomSheetTitle extends StatelessWidget {
  const BottomSheetTitle({
    super.key,
    required this.title,
    this.showHandle = true,
  });

  final String title;

  /// The drag handle only makes sense on a bottom sheet, not in a dialog.
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        if (showHandle) ...[
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: LinearGradient(
                  colors: [
                    context.primaryLight.withOpacity(0.6),
                    context.primaryLight.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ] else
          const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: title.s(18).w(700).copyWith(
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        ),
      ],
    );
  }
}
