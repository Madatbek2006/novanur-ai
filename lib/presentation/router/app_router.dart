import 'package:auto_route/auto_route.dart';
import 'package:nurnova_ai/core/enum/describe_img_type.dart';
import 'package:nurnova_ai/presentation/features/common/barcode/barcode_page.dart';
import 'package:nurnova_ai/presentation/features/common/chat/chat_page.dart';
import 'package:nurnova_ai/presentation/features/common/object_detection/object_detection_page.dart';
import 'package:nurnova_ai/presentation/features/common/scan_text/scan_text_page.dart';
import 'package:nurnova_ai/presentation/features/common/takephoto/take_photo_page.dart';
import 'package:nurnova_ai/presentation/features/home/features/dashboard/dashboard_page.dart';
import 'package:nurnova_ai/presentation/features/home/features/profile/profile_page.dart';
import 'package:nurnova_ai/presentation/features/home/home_page.dart';
import 'package:nurnova_ai/presentation/features/web/dashboard/web_dashboard_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [



        /// home
        AutoRoute(
          page: HomeRoute.page,
          path: '/home',
          initial: true,
          children: [
            AutoRoute(
              page: TakePhotoRoute.page,
              path: 'take_photo',
            ),
            // ML Kit doesn't run in browsers; the web build has its own dashboard.
            if (kIsWeb)
              AutoRoute(
                page: WebDashboardRoute.page,
                path: 'dashboard',
              )
            else
              AutoRoute(
                page: DashboardRoute.page,
                path: 'dashboard',
                // maintainState: true,
                // keepHistory: true,
              ),
            AutoRoute(
              page: ProfileRoute.page,
              path: 'profile',
              // maintainState: false,
              // keepHistory: false,
            )
          ],
        ),



        ///  take photo page
        AutoRoute(
          page: TakePhotoRoute.page,
          path: '/take_photo',
        ),

    ///  show result page
    AutoRoute(
      page: ChatRoute.page,
      path: '/chat',
    ),
    ///  show result page
    AutoRoute(
      page: BarcodeRoute.page,
      path: '/barcode',
    ),
    ///  show result page
    AutoRoute(
      page: ObjectDetectionRoute.page,
      path: '/object_detection',
    ),

    AutoRoute(
      page: ScanTextRoute.page,
      path: '/scan_text',
    ),

      ];
}
