import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:baiqavisit/core/enum/describe_img_type.dart';
import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/core/gen/assets/assets.gen.dart';
import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/presentation/router/app_router.dart';
import 'package:baiqavisit/presentation/support/colors/static_colors.dart';
import 'package:baiqavisit/presentation/support/cubit/base_page.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:baiqavisit/presentation/support/extensions/compressing_exts.dart';
import 'package:baiqavisit/presentation/widgets/app_bar/default_app_bar.dart';
import 'package:baiqavisit/presentation/widgets/bottom_sheet/bottom_sheet_title.dart';
import 'package:baiqavisit/presentation/widgets/button/custom_elevated_button.dart';
import 'package:baiqavisit/presentation/widgets/button/custom_outlined_button.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as lokiimage;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';

import 'take_photo_cubit.dart';

@RoutePage()
class TakePhotoPage
    extends BasePage<TakePhotoCubit, TakePhotoState, TakePhotoEvent> {
   TakePhotoPage({super.key});

  @override
  void onWidgetCreated(BuildContext context) {
    cubit(context).setInitialData();
  }

  @override
  void onEventEmitted(BuildContext context, TakePhotoEvent event) {
    switch (event.type) {
      case TakePhotoEventType.onShowTakenPhoto:
        _showTakenPhotoBottomSheet(context, cubit(context).states);
      case TakePhotoEventType.openResultScreen:
    }
  }

  @override
  Widget onWidgetBuild(BuildContext context, TakePhotoState state) {
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

  Widget _buildBody(BuildContext context, TakePhotoState state) {
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

  Widget _buildErrorBlock(BuildContext context, TakePhotoState state) {
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

  Widget _buildCameraViews(BuildContext context, TakePhotoState state) {
    final cameraController = state.cameraController;
    final double screenWidth = MediaQuery.of(context).size.width;

    final double rectangleWidth = screenWidth * 0.8;
    final double rectangleHeight = rectangleWidth * 4 / 3;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            color: context.appBarColor,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CameraPreview(cameraController!,
              child: Align(
                alignment: Alignment.bottomCenter,
                child:
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () async {
                          onTakePhoto(context,cameraController);
                        },
                        borderRadius: BorderRadius.circular(360),
                        child: Container(
                          height: 64,
                          width: 64,
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(360)
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(360)
                            )
                          ),
                        ),
                      ),
                      SizedBox(height: 64)
                    ],
                  )

              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onTakePhoto(BuildContext context, CameraController cameraController) async{
    HapticFeedback.heavyImpact();
    try {
      final XFile photo = await cameraController.takePicture();
      XFile compressed = await photo.compressPhoto();
      final Uint8List bytes = await compressed.readAsBytes();
      final String photoInBase64 = await _cropImage(bytes);

      cubit(context).setTakenPhoto(compressed, photoInBase64);
      cubit(context).showPicture(true);

      print("Cropped Image: $photoInBase64");
    } catch (e) {
      print("Error capturing image: $e");
    }
  }



  Future<String> _cropImage(Uint8List originalImageBytes) async {
    final lokiimage.Image? originalImage = lokiimage.decodeImage(originalImageBytes);
    if (originalImage == null) return '';

    final int imageWidth = originalImage.width;
    final int imageHeight = originalImage.height;

    const double targetAspectRatio = 3 / 4;

    int cropWidth = (imageWidth * 0.8).toInt();
    int cropHeight = ((imageWidth / targetAspectRatio) * 0.8).toInt();

    if (cropHeight > imageHeight) {
      cropHeight = imageHeight;
      cropWidth = (imageHeight * targetAspectRatio).toInt();
    }

    final int offsetX = ((imageWidth - cropWidth) / 2).toInt();
    final int offsetY = ((imageHeight - cropHeight) / 2.35).toInt();

    final lokiimage.Image croppedImage = lokiimage.copyCrop(
      originalImage,
      x: offsetX < 0 ? 0 : offsetX,
      y: offsetY < 0 ? 0 : offsetY,
      width: cropWidth,
      height: cropHeight,
    );

    // Convert the cropped image back to bytes
    final Uint8List croppedImageBytes =
        Uint8List.fromList(lokiimage.encodeJpg(croppedImage));
    return base64Encode(croppedImageBytes);
  }

  void _showTakenPhotoBottomSheet(
    BuildContext context,
    TakePhotoState state,
  ) {
    showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (BuildContext modalContext) {
        return Material(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              BottomSheetTitle(
                title: Strings.takeAttPreview,
                // onCloseClicked: () {
                //   context.router.pop();
                // },
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Strings.takeAttCheckImageBeforeSending
                    .s(16)
                    .w(500)
                    .copyWith(textAlign: TextAlign.center),
              ),
              SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.memory(
                  base64Decode(state.takenPhotoInBase64),
                  fit: BoxFit.cover,
                  height: 400,
                  width: 300,
                  alignment: Alignment.center,
                ),
              ),
              SizedBox(height: 24),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomElevatedButton(
                  text: Strings.commonRetakePhoto,
                  onPressed: () {
                    Navigator.of(context).pop();
                    HapticFeedback.heavyImpact();
                  },
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomElevatedButton(
                  text: Strings.commonApply,
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Navigator.of(context).pop();
                    context.router.pop();
                    // cubit(context).sendTakenAttendancePhoto();
                    context.router.push(ChatRoute( photoFile: state.takenPhotoFile!, type: DescribeImgType.question));

                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
