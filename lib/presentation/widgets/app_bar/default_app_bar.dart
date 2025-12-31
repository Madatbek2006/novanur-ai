import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/core/gen/assets/assets.gen.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final Color? titleTextColor;
  final Color backgroundColor;
  final VoidCallback onBackPressed;
  final PreferredSizeWidget? bottom;

  const DefaultAppBar({
    super.key,
    required this.titleText,
    this.titleTextColor,
    this.backgroundColor=Colors.transparent,
    required this.onBackPressed, this.bottom,
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
      title: titleText.w(500).s(16).c(titleTextColor??context.textPrimary),
      leading:   IconButton(onPressed: onBackPressed, icon: Assets.images.component.arrowLeft.svg(
        height: 24,
        width: 24,
        color: context.iconPrimary,)
      ),
      bottom: bottom,
    );
  }
}