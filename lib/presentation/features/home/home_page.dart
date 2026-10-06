import 'dart:ui';

import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/assets/assets.gen.dart';
import 'package:nurnova_ai/core/gen/assets/fonts.gen.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/presentation/router/app_router.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_page.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/support/theme/app_glass.dart';
import 'package:auto_route/auto_route.dart';
import 'package:nurnova_ai/presentation/widgets/button/bottom_nav_bar.dart';
import 'package:nurnova_ai/presentation/widgets/button/bottom_nav_item.dart';
import 'package:nurnova_ai/presentation/features/web/widgets/web_ui.dart';
import 'package:nurnova_ai/utils/extension/image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'home_cubit.dart';

@RoutePage()
class HomePage extends BasePage<HomeCubit, HomeState, HomeEvent> {
   HomePage({super.key});
   static final GlobalKey _bottomNavigationKey = GlobalKey();

  @override
  void onEventEmitted(BuildContext context, HomeEvent event) {
    switch (event.type) {
      case HomeEventType.onFcmTokenReceived:
        // context.router.replace(LoginRoute());
        break;
    }
  }

  @override
  Widget onWidgetBuild(BuildContext context, HomeState state) {
    return AutoTabsRouter(
      routes: [
        if (kIsWeb) WebDashboardRoute() else DashboardRoute(),
        ProfileRoute()
      ],
      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        if (kIsWeb && WebBreakpoints.isWide(context)) {
          return _buildWebLayout(context, tabsRouter, child);
        }
        return Stack(
          children: [
            child,
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: AppGlass.blurPanel,
                      sigmaY: AppGlass.blurPanel,
                    ),
                    child: Container(
                      height:MediaQuery.viewPaddingOf(context).bottom+48,
                    ),
                  )
              ),
            ),
            Positioned(
              bottom: MediaQuery.viewPaddingOf(context).bottom+16,
              left: 0,
              right: 0,
              child: BottomNavBar(
                key: _bottomNavigationKey,
                currentIndex: tabsRouter.activeIndex,
                onTap: (index) => tabsRouter.setActiveIndex(index),
                items: [
                  BottomNavItem(
                    context: context,
                    svgIcon: Assets.images.bottomBar.dashboard,
                    title: Strings.bottomNavigationHome,
                  ),
                    BottomNavItem(
                      context: context,
                      svgIcon: Assets.images.bottomBar.settings,
                      title: Strings.bottomNavigationSettings,
                    ),


                ],
              ),
            ),
          ],
        );
      },
    );
  }
  /// Wide browser windows: a side rail instead of the floating bottom bar.
  Widget _buildWebLayout(BuildContext context, TabsRouter tabsRouter, Widget child) {
    final extended = MediaQuery.sizeOf(context).width >= 1280;
    final selected = context.bottomSelectColor;
    final unselected = context.bottomUnSelectColor;

    NavigationRailDestination destination(SvgGenImage icon, String title) {
      return NavigationRailDestination(
        icon: icon.svgCustom(width: 24, height: 24, color: unselected),
        selectedIcon: icon.svgCustom(width: 24, height: 24, color: selected),
        label: Text(title),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: extended,
            minExtendedWidth: 220,
            backgroundColor: context.appBarColor,
            selectedIndex: tabsRouter.activeIndex,
            onDestinationSelected: tabsRouter.setActiveIndex,
            labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            useIndicator: true,
            indicatorColor: context.primaryLight.withValues(alpha: 0.18),
            // The rail replaces the ambient text style, so the app font must be named.
            selectedLabelTextStyle: TextStyle(
              fontFamily: FontFamily.inter,
              color: selected,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelTextStyle: TextStyle(
              fontFamily: FontFamily.inter,
              color: unselected,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 28),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Assets.images.logo.appLogo.image(width: 40, height: 40),
                  ),
                  if (extended) ...[
                    const SizedBox(width: 12),
                    "NurNova AI".s(18).w(700).c(context.textPrimary),
                  ],
                ],
              ),
            ),
            destinations: [
              destination(Assets.images.bottomBar.dashboard, Strings.bottomNavigationHome),
              destination(Assets.images.bottomBar.settings, Strings.bottomNavigationSettings),
            ],
          ),
          VerticalDivider(width: 1, thickness: 1, color: context.borderStroke),
          Expanded(child: child),
        ],
      ),
    );
  }
}
