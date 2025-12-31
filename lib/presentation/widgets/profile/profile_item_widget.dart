import 'package:flutter/material.dart';
import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/core/gen/assets/assets.gen.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';

class ProfileItemWidget extends StatelessWidget {
  const ProfileItemWidget({
    super.key,
    required this.name,
    required this.icon,
    required this.onClicked,
    this.color,
    this.topRadius = 0,
    this.bottomRadius = 0,
  });

  final String name;
  final SvgGenImage icon;
  final VoidCallback onClicked;
  final Color? color;
  final double topRadius;
  final double bottomRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
          onTap: () => onClicked(),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(bottomRadius),
            topLeft: Radius.circular(topRadius),
            topRight: Radius.circular(topRadius),
            bottomRight: Radius.circular(bottomRadius),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    icon.svg(width: 35, height: 35),
                    SizedBox(width: 16),
                    name.w(500).s(14).c(color ?? context.textPrimary)
                  ],
                )
              ],
            ),
          )),
    );
  }
}
