import 'package:flutter/material.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/assets/assets.gen.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/support/theme/app_glass.dart';

/// Row inside a settings group: tinted icon chip, label, chevron.
///
/// The chip used to be baked into each SVG as a hardcoded `#4393C7` rectangle,
/// so it ignored the theme and kept the palette of the old app. It is drawn
/// here now, and the icons are plain single-colour strokes.
class ProfileItemWidget extends StatelessWidget {
  const ProfileItemWidget({
    super.key,
    required this.name,
    required this.icon,
    required this.onClicked,
    this.color,
    this.tint,
    this.isDestructive = false,
    this.topRadius = 0,
    this.bottomRadius = 0,
  });

  final String name;
  final SvgGenImage icon;
  final VoidCallback onClicked;
  final Color? color;

  /// Chip colour. Defaults to the accent, or to red when [isDestructive].
  final Color? tint;

  final bool isDestructive;
  final double topRadius;
  final double bottomRadius;

  @override
  Widget build(BuildContext context) {
    final accent = tint ??
        (isDestructive ? const Color(0xFFE35B5B) : context.primaryLight);
    final labelColor =
        color ?? (isDestructive ? accent : context.textPrimary);

    final radius = BorderRadius.only(
      topLeft: Radius.circular(topRadius),
      topRight: Radius.circular(topRadius),
      bottomLeft: Radius.circular(bottomRadius),
      bottomRight: Radius.circular(bottomRadius),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onClicked,
        borderRadius: radius,
        splashColor: accent.withOpacity(0.10),
        highlightColor: Colors.white.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withOpacity(context.isDarkMode ? 0.22 : 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accent.withOpacity(0.28),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: icon.svg(
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: name.w(500).s(15).c(labelColor).copyWith(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: context.textPrimary.withOpacity(0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
