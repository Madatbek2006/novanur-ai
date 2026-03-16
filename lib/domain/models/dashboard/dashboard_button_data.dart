import 'package:baiqavisit/core/gen/assets/assets.gen.dart';
import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:flutter/widgets.dart';
enum DashboardButtonType{
  scanText,
  scanBarcode,
  describeScene,
  objectRecognition;
  // findObject;



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

      // case DashboardButtonType.findObject:
      //   return Strings.dashboardButtonTypeFindObject;

    }
  }


  Widget icon(BuildContext context){
    var icon=switch(this){
      DashboardButtonType.scanText => Assets.images.bottomBar.scanText,

      DashboardButtonType.scanBarcode => Assets.images.bottomBar.scanBarcode,

      DashboardButtonType.describeScene => Assets.images.bottomBar.mountainSnow,

      DashboardButtonType.objectRecognition => Assets.images.bottomBar.carFront,

      // DashboardButtonType.findObject => Assets.images.bottomBar.box
    };

    return icon.svg(
        height: 58,width: 58,
        color: context.iconPrimary
    );
  }
}