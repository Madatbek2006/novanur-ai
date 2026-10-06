import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/support/theme/app_glass.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget? child;
  final double elevation;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? height;
  final double? width;
  final List<BoxShadow>? boxShadow;
  final BoxBorder? border;
  final Gradient? gradient;
  final bool isGlass;
  final double blurSigma;

  const CustomCard({
    super.key,
    this.child,
    this.elevation = .3,
    this.margin = const EdgeInsets.all(1),
    this.borderRadius = AppGlass.cardAll,
    this.color,
    this.padding,
    this.height,
    this.width,
    this.boxShadow,
    this.border,
    this.gradient,
    this.isGlass = false,
    this.blurSigma = AppGlass.blurCard,
  });

  @override
  Widget build(BuildContext context) {
    final shape = borderRadius is BorderRadius
        ? (borderRadius as BorderRadius)
        : AppGlass.cardAll;

    if (isGlass) {
      return GlassSurface(
        margin: margin,
        width: width,
        height: height,
        padding: padding,
        blur: blurSigma,
        borderRadius: shape,
        child: child ?? const SizedBox.shrink(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: color ?? context.containerColorWhite,
        boxShadow: boxShadow,
        border: border,
        gradient: gradient,
      ),
      padding: padding,
      margin: margin,
      height: height,
      width: width,
      child: child,
    );
  }
}
