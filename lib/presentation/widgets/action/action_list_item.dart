import 'package:flutter/material.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/assets/assets.gen.dart';
import 'package:flutter/services.dart';

class ActionListItem extends StatelessWidget {
  const ActionListItem({
    super.key,
    required this.item,
    required this.title,
    required this.icon,
    this.color,
    required this.onClicked,
  });

  final dynamic item;
  final String title;
  final SvgGenImage icon;
  final Color? color;
  final Function(dynamic item) onClicked;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onClicked(item);
          HapticFeedback.selectionClick();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              icon.svg(width: 24, height: 24, color: color ?? Colors.black),
              SizedBox(width: 24),
              title.s(16).w(400).c(color ?? context.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
