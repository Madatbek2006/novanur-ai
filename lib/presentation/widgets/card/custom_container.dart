import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color backgroundColor;
  final Border? border;
  final BorderRadius borderRadius;

  const CustomContainer({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.backgroundColor = Colors.white,
    this.border,
    this.borderRadius = BorderRadius.zero,
  });

  const CustomContainer.defaultBorder({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.backgroundColor = Colors.white,
  })  : border = const Border.fromBorderSide(
          BorderSide(color: Color(0xFFDDDDDD), width: 1),
        ),
        borderRadius = const BorderRadius.all(Radius.circular(10));

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: border,
      ),
      child: child,
    );
  }
}
