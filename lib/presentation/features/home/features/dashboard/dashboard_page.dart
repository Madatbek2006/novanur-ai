import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:baiqavisit/core/enum/describe_img_type.dart';
import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/core/gen/assets/assets.gen.dart';
import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/domain/models/dashboard/dashboard_button_data.dart';
import 'package:baiqavisit/presentation/features/common/barcode/barcode_page.dart';
import 'package:baiqavisit/presentation/features/common/cameras/camera_view.dart';
import 'package:baiqavisit/presentation/features/common/cameras/object_detection_camera.dart';
import 'package:baiqavisit/presentation/router/app_router.dart';
import 'package:baiqavisit/presentation/support/colors/static_colors.dart';
import 'package:baiqavisit/presentation/support/cubit/base_page.dart';
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
import 'package:image/image.dart' as lokiimage;
import 'package:image_cropper/image_cropper.dart';
import 'package:logger/logger.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dashboard_cubit.dart';

@RoutePage()
class DashboardPage
    extends BasePage<DashboardCubit, DashboardState, DashboardEvent> {
  DashboardPage({super.key});

  @override
  void onWidgetCreated(BuildContext context) {
    cubit(context).setInitialData();
  }

  @override
  void onEventEmitted(BuildContext context, DashboardEvent event) {
    switch (event.type) {
      case DashboardEventType.onShowTakenPhoto:
        // _showTakenPhotoBottomSheet(context, cubit(context).states);
      case DashboardEventType.openResultScreen:
    }
  }

  @override
  Widget onWidgetBuild(BuildContext context, DashboardState state) {
    // if(state.isSendingRequest){
    //   showProgressDialog(context);
    // }
    return Scaffold(
      backgroundColor: context.backgroundWhiteColor,
      body: Container(
        child: _buildBody(context, state),
      ),
    );

  }

  Widget _buildBody(BuildContext context, DashboardState state) {
    if (state.isCameraInitLoading) {
      return _buildLoadingBlock();
    } else if (state.isCameraInitFailed) {
      return _buildErrorBlock(context, state);
    } else if (state.isCameraVisible) {
      return _buildCameraViews(context, state);
    } else {
      return _buildErrorBlock(context, state);
    }
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
                cubit(context).setupCamera();
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
    final double screenWidth = MediaQuery.of(context).size.width;

    final double rectangleWidth = screenWidth * 0.8;
    final double rectangleHeight = rectangleWidth * 4 / 3;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: switch(state.type){
              // null => _buildDefCam(context,state),
              //
              // DashboardButtonType.objectRecognition => _buildObjDetectCam(context,state),
              //
              // DashboardButtonType.barcode => _buildBarCode(context,state),
              //
              // DashboardButtonType.imageDescription => _buildDefCam(context,state),
              null =>  _buildDefCam(context,state),

              DashboardButtonType.scanText => _buildDefCam(context,state),

              DashboardButtonType.scanBarcode => _buildBarCode(context,state),

              DashboardButtonType.describeScene => _buildDefCam(context,state),

              DashboardButtonType.objectRecognition => _buildObjDetectCam(context,state),

              DashboardButtonType.findObject => _buildDefCam(context,state),
            }
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

  Widget _buildDefCam(BuildContext context,DashboardState state){
    return  CameraView(
      controller:state.cameraController,
        onControllerReady: (CameraController controller) {
          cubit(context).updateState((state)=>state.copyWith(cameraController: controller));
        },
    );
  }

  Widget _buildBarCode(BuildContext context,DashboardState state){
    return BarcodePage();
  }
  Widget _buildObjDetectCam(BuildContext context,DashboardState state){
    return ObjectDetectionCamera(
          onControllerReady: (CameraController controller) {
            cubit(context).updateState((state)=>state.copyWith(cameraController: controller));
          },
      // child: _buildBottomSheet(context,state)
    );
    // return  CameraView(controller:state.cameraController,
    //     child: _buildBottomSheet(context,state)
    // );
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
                                        if(state.type!=data) {
                                          cubit(context).setDashboardButtonType(data);
                                        }else {
                                          onClickDashboardButton(context, state.cameraController!, data);
                                        }
                                      },
                                    )
                      ).toList()
                    ),
                  ),



                  // child: ListView.separated(
                  //
                  //   scrollDirection: Axis.horizontal,
                  //   itemBuilder: (BuildContext context, int index) {
                  //
                  //     return DashboardButton(
                  //       isClicked: state.type==DashboardButtonType.values[index],
                  //       data: DashboardButtonType.values[index],
                  //       onPressed: (data){
                  //         if(state.type!=data) {
                  //           cubit(context).setDashboardButtonType(data);
                  //         }else {
                  //           onClickDashboardButton(context, state.cameraController!, data);
                  //         }
                  //       },
                  //     );
                  //   },
                  //   separatorBuilder: (BuildContext context, int index) {
                  //     return SizedBox(width: 4);
                  //   },
                  //   itemCount: DashboardButtonType.values.length,
                  // ),
                ),
              ),
            )


          ],
        )

    );
  }



  void onClickDashboardButton(BuildContext context,CameraController cameraController,DashboardButtonType type){
    switch(type){

      // case DashboardButtonType.objectRecognition:
      //   // context.router.push(ObjectDetectionRoute());
      //   break;
      //
      // case DashboardButtonType.barcode:
      //   // context.router.push(BarcodeRoute());
      //   break;
      // case DashboardButtonType.imageDescription:
      //   _showDialog(context,cameraController);
      //   break;
      case DashboardButtonType.scanText:
        _scanText(context,cameraController);
        break;
      case DashboardButtonType.scanBarcode:
        // context.router.push(BarcodeRoute());

      case DashboardButtonType.describeScene:
        _showDialog(context,cameraController);
        break;
      case DashboardButtonType.objectRecognition:
        context.router.push(ObjectDetectionRoute());
        break;

      case DashboardButtonType.findObject:


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
    // ProgressDialog.show(context);
    try {
      XFile photo = await cameraController.takePicture();
      if(isCompress) {
        photo = await photo.compressPhoto();
      }
      cubit(context).setTakenPhoto(photo);
      // ProgressDialog.hide(context);
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
  
  

}
