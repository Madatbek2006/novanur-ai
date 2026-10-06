import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nurnova_ai/core/enum/describe_img_type.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/domain/models/dashboard/dashboard_button_data.dart';
import 'package:nurnova_ai/presentation/features/common/cameras/app_camera_controller.dart';
import 'package:nurnova_ai/presentation/features/common/cameras/app_camera_view.dart';
import 'package:nurnova_ai/presentation/router/app_router.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_statefull_page.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/support/theme/app_glass.dart';
import 'package:nurnova_ai/presentation/widgets/action/dashboard_button.dart';

import 'dashboard_cubit.dart';

@RoutePage()
class DashboardPage
    extends BaseStatefulPage<DashboardCubit, DashboardState, DashboardEvent> {
  const DashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends BaseStatefulPageState<DashboardPage,
    DashboardCubit, DashboardState, DashboardEvent> {
  /// The app's only camera. Mode switches change what it analyses, never which
  /// camera is open.
  late final AppCameraController _camera;

  @override
  void onWidgetCreated() {
    _camera = AppCameraController(
      onBarcode: (value) => cubit().getProductData(value),
    );
    _camera.initialize(analysis: _analysisFor(cubit().states.type));
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  @override
  Widget onWidgetBuild(BuildContext context, DashboardState state) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: _backgroundGradient(context)),
        child: Stack(
          children: [
            Positioned.fill(child: AppCameraView(controller: _camera)),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewPaddingOf(context).bottom + 80,
                ),
                child: _buildModeSelector(context, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------- modes

  Widget _buildModeSelector(BuildContext context, DashboardState state) {
    return SizedBox(
      height: 128,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: DashboardButtonType.values
              .map(
                (type) => DashboardButton(
                  isClicked: state.type == type,
                  data: type,
                  onPressed: _onModePressed,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  /// First tap selects a mode, a second tap on the selected mode runs it.
  void _onModePressed(DashboardButtonType type) {
    if (cubit().states.type != type) {
      HapticFeedback.selectionClick();
      cubit().setDashboardButtonType(type);
      _camera.setAnalysis(_analysisFor(type));
      return;
    }
    _runAction(type);
  }

  CameraAnalysis _analysisFor(DashboardButtonType? type) {
    switch (type) {
      case DashboardButtonType.objectRecognition:
        return CameraAnalysis.objectDetection;
      case DashboardButtonType.scanBarcode:
        return CameraAnalysis.barcode;
      case DashboardButtonType.scanText:
      case DashboardButtonType.describeScene:
      case null:
        return CameraAnalysis.none;
    }
  }

  void _runAction(DashboardButtonType type) {
    switch (type) {
      case DashboardButtonType.scanText:
        _scanText();
        break;
      case DashboardButtonType.describeScene:
        _showDescribeOptions();
        break;
      case DashboardButtonType.scanBarcode:
      case DashboardButtonType.objectRecognition:
        // Live modes — results come off the camera stream, nothing to trigger.
        break;
    }
  }

  // ----------------------------------------------------------------- actions

  Future<void> _scanText() async {
    HapticFeedback.heavyImpact();
    final photo = await _camera.takePicture(compress: false);
    if (photo == null) return;

    cubit().setTakenPhoto(photo);
    await _camera.setFlash(FlashMode.off);
    if (!mounted) return;

    context.router.push(ScanTextRoute(photo: photo));
  }

  Future<void> _describeScene(DescribeImgType type) async {
    HapticFeedback.heavyImpact();
    final photo = await _camera.takePicture();
    if (photo == null) return;

    cubit().setTakenPhoto(photo);
    await _camera.setFlash(FlashMode.off);
    if (!mounted) return;

    context.router.push(ChatRoute(photoFile: photo, type: type));
  }

  void _showDescribeOptions() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (dialogContext) => _DescribeOptionsDialog(
        onSelected: (type) {
          Navigator.of(dialogContext).pop();
          _describeScene(type);
        },
      ),
    );
  }

  Gradient _backgroundGradient(BuildContext context) {
    final dark = context.isDarkMode;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: dark
          ? const [Color(0xFF0D1117), Color(0xFF161B27), Color(0xFF0A0E1A)]
          : const [Color(0xFFEEF2FF), Color(0xFFE1EAFF), Color(0xFFF0F4FF)],
    );
  }
}

/// Frosted-glass picker for the "describe scene" prompt variants.
class _DescribeOptionsDialog extends StatelessWidget {
  const _DescribeOptionsDialog({required this.onSelected});

  final void Function(DescribeImgType type) onSelected;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: GlassSurface(
        blur: AppGlass.blurPanel,
        borderRadius: AppGlass.panelAll,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: DescribeImgType.values
              .map(
                (type) => _GlassOption(
                  title: type.title,
                  onTap: () => onSelected(type),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _GlassOption extends StatelessWidget {
  const _GlassOption({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GlassSurface(
        blur: AppGlass.blurChip,
        borderRadius: AppGlass.chipAll,
        hasShadow: false,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: title.s(15).w(500),
        ),
      ),
    );
  }
}
