import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';

/// The single definition of the app's frosted-glass look.
///
/// Before this existed the same effect was re-typed at eleven call sites with
/// blur values of 10, 12, 20 and 30, border widths of 1, 1.2 and 1.5, and a
/// dozen different white opacities — so no two surfaces matched. Everything
/// glass now goes through [GlassSurface] and reads its numbers from here.
abstract class AppGlass {
  // ----------------------------------------------------------------- blur

  /// Full-width chrome: sheets, app bars, navigation, the composer.
  static const double blurPanel = 24;

  /// Cards and dialogs sitting inside a screen.
  static const double blurCard = 18;

  /// Small controls: mode tiles, option rows, inline fields.
  static const double blurChip = 14;

  // ---------------------------------------------------------------- shape

  static const double radiusChip = 18;
  static const double radiusCard = 22;
  static const double radiusPanel = 28;
  static const double radiusPill = 999;

  static const double borderWidth = 1.2;

  static const BorderRadius chipAll =
      BorderRadius.all(Radius.circular(radiusChip));
  static const BorderRadius cardAll =
      BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius panelAll =
      BorderRadius.all(Radius.circular(radiusPanel));

  /// Top-rounded, for sheets and docked bars.
  static const BorderRadius sheet =
      BorderRadius.vertical(top: Radius.circular(radiusPanel));

  // ---------------------------------------------------------------- fills

  /// Base translucent fill. Light values sit higher than the old ad-hoc ones
  /// so body text keeps its contrast over a bright camera preview.
  static List<Color> fill(BuildContext context) => context.isDarkMode
      ? [
          Colors.white.withOpacity(0.16),
          Colors.white.withOpacity(0.07),
        ]
      : [
          Colors.white.withOpacity(0.86),
          Colors.white.withOpacity(0.62),
        ];

  /// Fill for a selected / accented surface.
  static List<Color> accentFill(BuildContext context) {
    final accent = context.primaryLight;
    return context.isDarkMode
        ? [accent.withOpacity(0.46), accent.withOpacity(0.22)]
        : [accent.withOpacity(0.34), accent.withOpacity(0.16)];
  }

  /// The lit edge that reads as the rim of a pane of glass.
  static Color borderColor(BuildContext context) => context.isDarkMode
      ? Colors.white.withOpacity(0.20)
      : Colors.white.withOpacity(0.78);

  static Color accentBorderColor(BuildContext context) =>
      context.primaryLight.withOpacity(context.isDarkMode ? 0.60 : 0.48);

  // -------------------------------------------------------------- shadows

  /// Two layers: a wide ambient pool plus a tighter key shadow. Accented
  /// surfaces add a coloured glow instead of a heavier black.
  static List<BoxShadow> shadow(BuildContext context, {bool accent = false}) {
    final dark = context.isDarkMode;

    return [
      if (accent)
        BoxShadow(
          color: context.primaryLight.withOpacity(dark ? 0.34 : 0.26),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      BoxShadow(
        color: Colors.black.withOpacity(dark ? 0.34 : 0.10),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(dark ? 0.22 : 0.05),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];
  }
}

/// Where a [GlassSurface] draws its rim.
enum GlassEdge {
  /// All the way round — cards, dialogs, chips.
  all,

  /// Only along the top — sheets and bars docked to a screen edge.
  top,

  /// Only along the bottom — app bars.
  bottom,

  /// No rim.
  none,
}

/// A frosted panel: blur behind, translucent gradient fill, lit rim, soft
/// shadow. The one place the effect is implemented.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = AppGlass.cardAll,
    this.blur = AppGlass.blurCard,
    this.edge = GlassEdge.all,
    this.padding,
    this.width,
    this.height,
    this.margin,
    this.isAccented = false,
    this.hasShadow = true,
    this.onTap,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blur;
  final GlassEdge edge;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;

  /// Renders the accent-tinted variant used for selected states.
  final bool isAccented;

  final bool hasShadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final rim = isAccented
        ? AppGlass.accentBorderColor(context)
        : AppGlass.borderColor(context);

    Widget content = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isAccented
                  ? AppGlass.accentFill(context)
                  : AppGlass.fill(context),
            ),
            border: _border(rim),
          ),
          // Text inside a glass panel has no Material ancestor of its own —
          // without this Flutter paints it with the yellow "unstyled text"
          // underline.
          child: Material(
            type: MaterialType.transparency,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      content = Stack(
        children: [
          content,
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: borderRadius,
                splashColor: context.primaryLight.withOpacity(0.12),
                highlightColor: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
        ],
      );
    }

    // The shadow has to sit outside the clip, or it gets cut away.
    return Container(
      margin: margin,
      decoration: hasShadow
          ? BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: AppGlass.shadow(context, accent: isAccented),
            )
          : null,
      child: content,
    );
  }

  BoxBorder? _border(Color color) {
    switch (edge) {
      case GlassEdge.all:
        return Border.all(color: color, width: AppGlass.borderWidth);
      case GlassEdge.top:
        return Border(
          top: BorderSide(color: color, width: AppGlass.borderWidth),
        );
      case GlassEdge.bottom:
        return Border(
          bottom: BorderSide(color: color, width: AppGlass.borderWidth),
        );
      case GlassEdge.none:
        return null;
    }
  }
}

/// The frosted shell every bottom sheet sits in: top-rounded, lit top rim,
/// grabber, safe-area aware.
///
/// Pass the body only — the chrome is identical everywhere by construction.
class GlassSheet extends StatelessWidget {
  const GlassSheet({
    super.key,
    required this.child,
    this.showGrabber = true,
  });

  final Widget child;
  final bool showGrabber;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppGlass.sheet,
      child: GlassSurface(
        blur: AppGlass.blurPanel,
        borderRadius: AppGlass.sheet,
        edge: GlassEdge.top,
        hasShadow: false,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showGrabber) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppGlass.radiusPill),
                      gradient: LinearGradient(
                        colors: [
                          context.primaryLight.withOpacity(0.6),
                          context.primaryLight.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
