import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:baiqavisit/core/enum/describe_img_type.dart';
import 'package:baiqavisit/core/extensions/list_extensions.dart';
import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/core/gen/assets/assets.gen.dart';
import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/domain/models/dashboard/dashboard_button_data.dart';
import 'package:baiqavisit/presentation/application/manager/object_detection_manager.dart';
import 'package:baiqavisit/presentation/features/common/barcode/barcode_page.dart';
import 'package:baiqavisit/presentation/features/common/cameras/camera_view.dart';
import 'package:baiqavisit/presentation/features/common/cameras/object_detection_camera.dart';
import 'package:baiqavisit/presentation/router/app_router.dart';
import 'package:baiqavisit/presentation/support/colors/static_colors.dart';
import 'package:baiqavisit/presentation/support/cubit/base_page.dart';
import 'package:baiqavisit/presentation/support/cubit/base_statefull_page.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:baiqavisit/presentation/support/extensions/compressing_exts.dart';
import 'package:baiqavisit/presentation/widgets/action/dashboard_button.dart';
import 'package:baiqavisit/presentation/widgets/app_bar/default_app_bar.dart';
import 'package:baiqavisit/presentation/widgets/bottom_sheet/bottom_sheet_title.dart';
import 'package:baiqavisit/presentation/widgets/button/custom_elevated_button.dart';
import 'package:baiqavisit/presentation/widgets/button/custom_outlined_button.dart';
import 'package:baiqavisit/presentation/widgets/card/custom_card.dart';
import 'package:baiqavisit/presentation/widgets/dialog/progress_dialog.dart';
import 'package:baiqavisit/utils/extension/map_with_index.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image/image.dart' as lokiimage;
import 'package:image_cropper/image_cropper.dart';
import 'package:logger/logger.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dashboard_cubit.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

@RoutePage()
class DashboardPage
    extends BaseStatefulPage<DashboardCubit, DashboardState, DashboardEvent> {
  DashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardState();


}





class _DashboardState extends BaseStatefulPageState<DashboardPage,DashboardCubit, DashboardState, DashboardEvent> {
  CameraController? _controller;




  @override
  void onWidgetCreated() {
    // cubit().setInitialData();
  }


  @override
  Widget onWidgetBuild(BuildContext context, DashboardState state) {
    return Scaffold(
      backgroundColor: context.backgroundWhiteColor,
      body: Container(
        child: _buildBody(context, state),
      ),
    );

  }

  Widget _buildBody(BuildContext context, DashboardState state) {
    // if (state.isCameraInitLoading) {
    //   return _buildLoadingBlock();
    // } else if (state.isCameraInitFailed) {
    //   return _buildErrorBlock(context, state);
    // } else if (state.isCameraVisible) {
      return _buildCameraViews(context, state);
    // } else {
    //   return _buildErrorBlock(context, state);
    // }
  }


  Widget _buildLoadingBlock() {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(StaticColors.buttonColor),
      ),
    );
  }

  Widget _buildErrorBlock(BuildContext context, DashboardState state) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Strings.commonCameraError
                .w(500)
                .s(15)
                .c(context.textPrimary)
                .copyWith(textAlign: TextAlign.center, softWrap: true),
            SizedBox(height: 32),
            CustomOutlinedButton(
              buttonHeight: 42,
              text: Strings.commonRestartCamera,
              strokeColor: StaticColors.buttonColor,
              onPressed: () {
                HapticFeedback.heavyImpact();
                cubit().setupCamera();
              },
            ),
            SizedBox(height: 20),
            CustomElevatedButton(
              buttonHeight: 42,
              text: Strings.commonOpenSettings,
              onPressed: () {
                HapticFeedback.heavyImpact();
                openAppSettings();
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraViews(BuildContext context, DashboardState state) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Align(
              alignment: Alignment.topCenter,
              child:
              cubit().states.type==DashboardButtonType.scanBarcode?_buildBarCode(context): _buildDefCam(context),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom+80),
                child: _buildBottomSheet(context,state),
              )
          )
        ],
      ),
    );
  }



  void onClickDashboardButton(BuildContext context,CameraController cameraController,DashboardButtonType type){
    Logger().d("TTT=>type: $type");
    switch(type){

      case DashboardButtonType.scanText:
        _scanText(context,cameraController);
        break;
      case DashboardButtonType.scanBarcode:
      // context.router.push(BarcodeRoute());
        break;

      case DashboardButtonType.describeScene:
        _showDialog(context,cameraController);
        break;
      case DashboardButtonType.objectRecognition:
      // context.router.push(ObjectDetectionRoute());
        break;

      // case DashboardButtonType.findObject:


    }
  }



  void _scanText(BuildContext context,CameraController cameraController)async {
    var photo= await onTakePhoto(context,cameraController,isCompress: false);

    Logger().d("TTT=>photo: ${photo}//${photo?.path}");
    if(photo==null)return;
    await cameraController.setFlashMode(FlashMode.off);
    context.router.push(ScanTextRoute(photo: photo));

  }

  Future<XFile?> onTakePhoto(BuildContext context, CameraController cameraController,{bool isCompress=true}) async{
    HapticFeedback.heavyImpact();
    try {
      XFile photo = await cameraController.takePicture();
      if(isCompress) {
        photo = await photo.compressPhoto();
      }
      cubit().setTakenPhoto(photo);
      Logger().d("TTT=>Success capturing image");
      return photo;
    } catch (e) {
      Logger().d("TTT=>Error capturing image: $e");
      ProgressDialog.hide(context);
      return null;
    }
  }


  void _showDialog(BuildContext context,CameraController cameraController){
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...DescribeImgType.values.map((type)=>
                  _buildAction(dialogContext, type.title,() async{
                    Navigator.of(dialogContext).pop();
                    var photo= await onTakePhoto(context,cameraController);
                    await cameraController.setFlashMode(FlashMode.off);
                    if(photo==null) return;
                    context.router.push(ChatRoute( photoFile: photo!, type: type));

                  })
              )
            ],
          ),
        );
      },
    );
  }


  Widget _buildAction(BuildContext context,String title,Function() onTab){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTab,
        child: CustomCard(
          borderRadius: BorderRadius.circular(16),
          color: context.appBarColor,
          width: double.infinity,
          border: Border.all(width: 1,color: context.textPrimary),
          padding: EdgeInsets.symmetric(vertical: 16,horizontal: 16),
          child: title.s(14).w(500),
        ),
      ),
    );
  }


  Widget _buildDefCam(BuildContext context){
    return  CameraView(
      controller:_controller,
      isObjRec: cubit().states.type==DashboardButtonType.objectRecognition,
      onControllerReady: (CameraController controller) {
        _controller=controller;
      },
    );
  }

  Widget _buildBarCode(BuildContext context){
    return MobileScanner(
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          cubit().getProductData(barcode.rawValue);
          Logger().d('TTT=>Найден код: ${barcode.rawValue}');
        }
      },
    );
  }
  Widget _buildObjDetectCam(BuildContext context,DashboardState state){
    return ObjectDetectionCamera(
      onControllerReady: (CameraController controller) {
        cubit().updateState((state)=>state.copyWith(cameraController: controller));
      },
    );
  }


  Widget _buildBottomSheet(BuildContext context, DashboardState state) {
    return Align(
        alignment: Alignment.bottomCenter,
        child:
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 128,
              child: Container(
                // color: context.appBarColor,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: DashboardButtonType.values.map(
                                (e)=>DashboardButton(
                              isClicked: state.type==e,
                              data: e,
                              onPressed: (data){
                                Logger().d("TTT=>data: $data");
                                if(state.type!=data) {
                                  cubit().setDashboardButtonType(data);
                                }else {
                                  onClickDashboardButton(context, _controller!, data);
                                }
                                setState(() {});
                              },
                            )
                        ).toList()
                    ),
                  ),
                ),
              ),
            )


          ],
        )

    );
  }

}
