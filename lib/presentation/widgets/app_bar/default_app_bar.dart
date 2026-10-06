import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/assets/assets.gen.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/support/theme/app_glass.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({
    super.key,
    required this.titleText,
    required this.onBackPressed,
    this.titleTextColor,
    this.backgroundColor,
    this.actions,
    this.bottom,
  });

  final String titleText;
  final VoidCallback onBackPressed;
  final Color? titleTextColor;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(64 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final dark = context.isDarkMode;

    return AppBar(
      backgroundColor: Colors.transparent,
      systemOverlayStyle:
          dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      toolbarHeight: 64,
      flexibleSpace: GlassSurface(
        blur: AppGlass.blurPanel,
        borderRadius: BorderRadius.zero,
        edge: GlassEdge.bottom,
        hasShadow: false,
        child: const SizedBox.expand(),
      ),
      title: titleText.w(600).s(17).c(titleTextColor ?? context.textPrimary),
      leading: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          onBackPressed();
        },
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        icon: Assets.images.component.arrowLeft.svg(
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(context.iconPrimary, BlendMode.srcIn),
        ),
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}
