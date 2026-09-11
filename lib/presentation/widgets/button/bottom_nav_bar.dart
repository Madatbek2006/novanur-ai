import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/support/theme/app_glass.dart';
import 'package:nurnova_ai/presentation/widgets/button/bottom_nav_item.dart';
import 'package:nurnova_ai/utils/extension/image.dart';

/// Floating frosted navigation pill.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<BottomNavItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassSurface(
        height: 70,
        blur: AppGlass.blurPanel,
        borderRadius: BorderRadius.circular(AppGlass.radiusPill),
        padding: const EdgeInsets.all(7),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / items.length;

            return Stack(
              children: [
                // Selection pill slides between destinations.
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  left: currentIndex * itemWidth,
                  width: itemWidth,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppGlass.radiusPill),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppGlass.accentFill(context),
                      ),
                      border: Border.all(
                        color: AppGlass.accentBorderColor(context),
                        width: AppGlass.borderWidth,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = currentIndex == index;

                    return Expanded(
                      child: Semantics(
                        button: true,
                        selected: isSelected,
                        label: item.title,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (isSelected) return;
                            HapticFeedback.selectionClick();
                            onTap(index);
                          },
                          child: AnimatedScale(
                            scale: isSelected ? 1.0 : 0.92,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                item.svgIcon.svgCustom(
                                  color: isSelected
                                      ? context.bottomSelectColor
                                      : context.bottomUnSelectColor,
                                  width: 22,
                                  height: 22,
                                ),
                                const SizedBox(height: 4),
                                item.title
                                    .s(11)
                                    .w(isSelected ? 700 : 500)
                                    .c(isSelected
                                        ? context.bottomSelectColor
                                        : context.bottomUnSelectColor)
                                    .copyWith(
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
