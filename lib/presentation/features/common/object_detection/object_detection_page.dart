import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/presentation/features/common/cameras/app_camera_controller.dart';
import 'package:nurnova_ai/presentation/features/common/cameras/app_camera_view.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_statefull_page.dart';
import 'package:nurnova_ai/presentation/widgets/app_bar/default_app_bar.dart';

import 'object_detection_cubit.dart';

@RoutePage()
class ObjectDetectionPage extends BaseStatefulPage<ObjectDetectionCubit,
    ObjectDetectionState, ObjectDetectionEvent> {
  const ObjectDetectionPage({super.key});

  @override
  State<StatefulWidget> createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends BaseStatefulPageState<
    ObjectDetectionPage,
    ObjectDetectionCubit,
    ObjectDetectionState,
    ObjectDetectionEvent> {
  late final AppCameraController _camera;

  @override
  void onWidgetCreated() {
    _camera = AppCameraController();
    _camera.initialize(analysis: CameraAnalysis.objectDetection);
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  @override
  Widget onWidgetBuild(BuildContext context, ObjectDetectionState state) {
    return Scaffold(
      appBar: DefaultAppBar(
        titleText: Strings.dashboardButtonTypeObjectRecognition,
        onBackPressed: () => context.router.popForced(),
      ),
      body: AppCameraView(controller: _camera),
    );
  }
}
