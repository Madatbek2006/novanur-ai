import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/presentation/features/common/cameras/app_camera_controller.dart';
import 'package:nurnova_ai/presentation/features/common/cameras/object_painter.dart';
import 'package:nurnova_ai/presentation/support/colors/static_colors.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/widgets/button/custom_elevated_button.dart';
import 'package:nurnova_ai/presentation/widgets/button/custom_outlined_button.dart';
import 'package:permission_handler/permission_handler.dart';

/// Renders whatever [controller] is currently showing: the live preview, the
/// detection overlay when object detection is active, and the loading / error
/// states. This is the only widget in the app that builds a [CameraPreview].
class AppCameraView extends StatelessWidget {
  const AppCameraView({
    super.key,
    required this.controller,
    this.overlay,
  });

  final AppCameraController controller;

  /// Drawn on top of the preview — capture buttons, framing guides, and so on.
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final camera = controller.camera;

        if (!controller.isReady || camera == null) {
          return _CameraPlaceholder(controller: controller);
        }

        final previewSize = camera.value.previewSize;

        return Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(camera),
            if (controller.analysis == CameraAnalysis.objectDetection &&
                previewSize != null)
              Positioned.fill(
                child: CustomPaint(
                  painter: ObjectPainter(
                    objects: controller.objects,
                    previewSize: previewSize,
                  ),
                ),
              ),
            if (overlay != null) overlay!,
          ],
        );
      },
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder({required this.controller});

  final AppCameraController controller;

  @override
  Widget build(BuildContext context) {
    switch (controller.status) {
      case CameraStatus.idle:
      case CameraStatus.initializing:
        return Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(StaticColors.buttonColor),
          ),
        );
      case CameraStatus.ready:
      case CameraStatus.permissionDenied:
      case CameraStatus.unavailable:
      case CameraStatus.error:
        return _buildError(context);
    }
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Strings.commonCameraError
                .w(500)
                .s(15)
                .c(context.textPrimary)
                .copyWith(textAlign: TextAlign.center, softWrap: true),
            const SizedBox(height: 32),
            CustomOutlinedButton(
              buttonHeight: 42,
              text: Strings.commonRestartCamera,
              strokeColor: StaticColors.buttonColor,
              onPressed: () {
                HapticFeedback.heavyImpact();
                controller.retry();
              },
            ),
            const SizedBox(height: 20),
            if (controller.status == CameraStatus.permissionDenied)
              CustomElevatedButton(
                buttonHeight: 42,
                text: Strings.commonOpenSettings,
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  openAppSettings();
                },
              ),
          ],
        ),
      ),
    );
  }
}
