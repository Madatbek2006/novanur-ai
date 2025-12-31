import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final Color? textColor;
  final Color backgroundColor;

  const EmptyAppBar({
    super.key,
    required this.titleText,
    this.textColor,
    this.backgroundColor=Colors.transparent,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    var isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: backgroundColor,
      systemOverlayStyle: isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 64,
      title: titleText.w(500).s(16).c(textColor??context.textPrimary),
    );
  }
}
