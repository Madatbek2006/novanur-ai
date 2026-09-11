import 'package:nurnova_ai/core/gen/assets/assets.gen.dart';
import 'package:flutter/cupertino.dart';

class BottomNavItem  {
  final SvgGenImage svgIcon;
  final String title;
  final BuildContext context;

  BottomNavItem({
    required this.context,
    required this.svgIcon,
    required this.title,
  });
}
