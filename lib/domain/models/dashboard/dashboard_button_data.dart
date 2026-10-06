import 'package:nurnova_ai/core/gen/assets/assets.gen.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:flutter/widgets.dart';

enum DashboardButtonType{
  scanText,
  scanBarcode,
  describeScene,
  objectRecognition;

  String get title {
    switch(this){
      case DashboardButtonType.scanText:
        return Strings.dashboardButtonTypeScanText;

      case DashboardButtonType.scanBarcode:
        return Strings.dashboardButtonTypeScanBarcode;

      case DashboardButtonType.describeScene:
        return Strings.dashboardButtonTypeDescribeScene;

      case DashboardButtonType.objectRecognition:
        return Strings.dashboardButtonTypeObjectRecognition;
    }
  }

  Widget icon(BuildContext context, {Color? color, double size = 32}) {
    // Lucide line icons, picked to match what each mode actually does — the
    // previous set used a mountain for "describe scene" and a car for
    // "object recognition".
    final icon = switch (this) {
      DashboardButtonType.scanText => Assets.images.bottomBar.scanText,
      DashboardButtonType.scanBarcode => Assets.images.bottomBar.scanBarcode,
      DashboardButtonType.describeScene => Assets.images.bottomBar.sparkles,
      DashboardButtonType.objectRecognition =>
        Assets.images.bottomBar.scanSearch,
    };

    return icon.svg(
      height: size,
      width: size,
      colorFilter: ColorFilter.mode(
        color ?? context.iconPrimary,
        BlendMode.srcIn,
      ),
    );
  }
}
