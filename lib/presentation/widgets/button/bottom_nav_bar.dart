import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:baiqavisit/presentation/widgets/button/bottom_nav_item.dart';
import 'package:baiqavisit/presentation/widgets/card/custom_card.dart';
import 'package:baiqavisit/utils/extension/image.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavItem> items;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        borderRadius: BorderRadius.circular(32),
        child: CustomCard(
          color: context.appBarColor,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          borderRadius: BorderRadius.circular(32),
          height: 64,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double totalWidth = constraints.maxWidth;



              final double itemWidth = (totalWidth-12) / items.length;

              final double indicatorWidth = itemWidth + 12;

              final double indicatorLeft =currentIndex*itemWidth;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    left: indicatorLeft,
                    width: indicatorWidth,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.primaryLight.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  // Элементы навигации
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Row(
                      children: items.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final BottomNavItem item = entry.value;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => onTap(index),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    item.svgIcon.svgCustom(
                                      color: currentIndex == index
                                          ? context.bottomSelectColor
                                          : context.bottomUnSelectColor,
                                      width: 24,
                                      height: 24,
                                    ),
                                    const SizedBox(height: 4),
                              item.title.s(12).w(600).c( currentIndex == index
                                  ? context.bottomSelectColor
                                  : context.bottomUnSelectColor,)
                              .copyWith(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1
                              )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}