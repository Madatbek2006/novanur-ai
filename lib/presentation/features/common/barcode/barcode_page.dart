
import 'package:auto_route/auto_route.dart';
import 'package:baiqavisit/presentation/support/cubit/base_page.dart';
import 'package:baiqavisit/presentation/widgets/app_bar/default_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'barcode_cubit.dart';

@RoutePage()
class BarcodePage
    extends BasePage<BarcodeCubit, BarcodeState, BarcodeEvent> {
   BarcodePage({super.key,this.child,});
   final Widget? child;

  @override
  void onWidgetCreated(BuildContext context) {
  }


  @override
  Widget onWidgetBuild(BuildContext context, BarcodeState state) {
    return _buildBody(context, state);
  }

  Widget _buildBody(BuildContext context, BarcodeState state) {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              cubit(context).getProductData(barcode.rawValue);
              Logger().d('TTT=>Найден код: ${barcode.rawValue}');
            }
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: child
        )
      ],
    );
  }

}


