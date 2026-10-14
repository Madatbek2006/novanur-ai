import 'package:nurnova_ai/core/gen/assets/assets.gen.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:flutter/widgets.dart';

enum DashboardButtonType{
  scanText,
  scanBarcode,
  describeScene,
  objectRecognition,

  /// Мебель и предметы комнаты — своей моделью (YOLO на HomeObjects-3K).
  /// Только в приложении: в браузере эта модель не запускается.
  homeObjects,

  /// Поиск одного предмета: пользователь называет его, а камера говорит,
  /// когда он в кадре. Как «Find Object» в Envision. Только в приложении.
  findObject;

  /// Режимы сайта — все, кроме тех, что работают только на телефоне.
  static List<DashboardButtonType> get web => values
      .where((t) =>
          t != DashboardButtonType.homeObjects &&
          t != DashboardButtonType.findObject)
      .toList();

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

      case DashboardButtonType.homeObjects:
        return Strings.dashboardButtonTypeHomeObjects;

      case DashboardButtonType.findObject:
        return Strings.dashboardButtonTypeFindObject;
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
      DashboardButtonType.homeObjects => Assets.images.bottomBar.sofa,
      DashboardButtonType.findObject => Assets.images.bottomBar.locateFixed,
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
