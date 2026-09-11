import 'dart:ui';

import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/assets/assets.gen.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/presentation/router/app_router.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_page.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/support/theme/app_glass.dart';
import 'package:auto_route/auto_route.dart';
import 'package:nurnova_ai/presentation/widgets/button/bottom_nav_bar.dart';
import 'package:nurnova_ai/presentation/widgets/button/bottom_nav_item.dart';
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
        DashboardRoute(),
        ProfileRoute()
      ],
      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
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
}
