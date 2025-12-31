
import 'package:auto_route/auto_route.dart';
import 'package:baiqavisit/presentation/features/common/cameras/object_detection_camera.dart';
import 'package:baiqavisit/presentation/support/cubit/base_page.dart';
import 'package:baiqavisit/presentation/widgets/app_bar/default_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'object_detection_cubit.dart';

@RoutePage()
class ObjectDetectionPage
    extends BasePage<ObjectDetectionCubit, ObjectDetectionState, ObjectDetectionEvent> {
   ObjectDetectionPage({super.key});

  @override
  void onWidgetCreated(BuildContext context) {
  }


  @override
  Widget onWidgetBuild(BuildContext context, ObjectDetectionState state) {
    return Scaffold(
      appBar: DefaultAppBar(titleText: 'ObjectDetection',onBackPressed: (){
        context.router.popForced();
      }, ),
      body: Container(
        child: _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ObjectDetectionState state) {
    // return ObjectDetectionCamera();
    return Container();
  }

}


