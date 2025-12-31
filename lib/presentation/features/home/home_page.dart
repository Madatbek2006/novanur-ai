import 'dart:ui';

import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/core/gen/assets/assets.gen.dart';
import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/presentation/router/app_router.dart';
import 'package:baiqavisit/presentation/support/cubit/base_page.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:auto_route/auto_route.dart';
import 'package:baiqavisit/presentation/widgets/button/bottom_nav_bar.dart';
import 'package:baiqavisit/presentation/widgets/button/bottom_nav_item.dart';
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
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
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

//  BottomNavigationBarItem(
//                     label: Strings.bottomNavigationHome,
//                     tooltip: Strings.bottomNavigationHome,
//                     icon: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Assets.images.bottomBar.dashboard.svg(),
//                     ),
//                     activeIcon: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Assets.images.bottomBar.dashboardActive.svg(),
//                     ),
//                   ),
//                   BottomNavigationBarItem(
//                     label: Strings.bottomNavigationSettings,
//                     icon: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Assets.images.bottomBar.settings.svg(),
//                     ),
//                     activeIcon: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Assets.images.bottomBar.settingsActive.svg(),
//                     ),
//                   ),