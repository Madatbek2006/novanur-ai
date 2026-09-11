import 'package:flutter/material.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/domain/models/dashboard/dashboard_button_data.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/support/theme/app_glass.dart';

/// Mode tile on the dashboard — a frosted chip over the live camera.
class DashboardButton extends StatelessWidget {
  const DashboardButton({
    super.key,
    required this.data,
    required this.isClicked,
    this.onPressed,
  });

  final DashboardButtonType data;
  final bool isClicked;
  final Function(DashboardButtonType)? onPressed;

  @override
  Widget build(BuildContext context) {
    final iconColor = isClicked
        ? (context.isDarkMode ? Colors.white : context.primaryLight)
        : context.textPrimary.withOpacity(0.85);

    return SizedBox(
      width: 96,
      child: Semantics(
        button: true,
        selected: isClicked,
        label: data.title,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isClicked ? 1.0 : 0.94,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: GlassSurface(
                width: 76,
                height: 76,
                blur: AppGlass.blurChip,
                borderRadius: AppGlass.chipAll,
                isAccented: isClicked,
                onTap: () => onPressed?.call(data),
                child: Center(child: data.icon(context, color: iconColor)),
              ),
            ),
            const SizedBox(height: 8),
            // The label sits directly on the camera feed, so it carries its own
            // shadow — otherwise it disappears over a bright frame.
            Text(
              data.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1.25,
                fontWeight: isClicked ? FontWeight.w700 : FontWeight.w600,
                color: isClicked ? context.primaryLight : context.textPrimary,
                shadows: [
                  Shadow(
                    color: (context.isDarkMode ? Colors.black : Colors.white)
                        .withOpacity(0.85),
                    blurRadius: 6,
                  ),
                  Shadow(
                    color: (context.isDarkMode ? Colors.black : Colors.white)
                        .withOpacity(0.65),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
