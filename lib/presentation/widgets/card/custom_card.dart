import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
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

  const CustomCard({
    super.key,
    this.child,
    this.elevation = .3,
    this.margin = const EdgeInsets.all(1),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.color,
    this.padding, this.height, this.width,
    this.boxShadow, this.border,
    this.gradient,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: color ?? context.containerColorWhite,
          boxShadow: boxShadow,
          border: border,
          gradient: gradient
      ),
      padding: padding,
      margin: margin,
      height: height,
      width: width,
      child: child,

    );
  }
}
