import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:nurnova_ai/presentation/features/common/cameras/app_camera_controller.dart';
import 'package:nurnova_ai/presentation/features/common/cameras/app_camera_view.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_statefull_page.dart';

import 'barcode_cubit.dart';

@RoutePage()
class BarcodePage
    extends BaseStatefulPage<BarcodeCubit, BarcodeState, BarcodeEvent> {
  const BarcodePage({super.key, this.child});

  /// Drawn over the preview, pinned to the bottom.
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _BarcodePageState();
}

class _BarcodePageState extends BaseStatefulPageState<BarcodePage, BarcodeCubit,
    BarcodeState, BarcodeEvent> {
  late final AppCameraController _camera;

  @override
  void onWidgetCreated() {
    _camera = AppCameraController(
      onBarcode: (value) => cubit().getProductData(value),
    );
    _camera.initialize(analysis: CameraAnalysis.barcode);
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  @override
  Widget onWidgetBuild(BuildContext context, BarcodeState state) {
    return AppCameraView(
      controller: _camera,
      overlay: widget.child == null
          ? null
          : Align(alignment: Alignment.bottomCenter, child: widget.child),
    );
  }
}
