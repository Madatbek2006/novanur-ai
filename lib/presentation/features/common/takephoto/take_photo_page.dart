import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as lokiimage;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nurnova_ai/core/enum/describe_img_type.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/presentation/features/common/cameras/app_camera_controller.dart';
import 'package:nurnova_ai/presentation/features/common/cameras/app_camera_view.dart';
import 'package:nurnova_ai/presentation/router/app_router.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_statefull_page.dart';
import 'package:nurnova_ai/presentation/widgets/bottom_sheet/bottom_sheet_title.dart';
import 'package:nurnova_ai/presentation/widgets/button/custom_elevated_button.dart';

import 'take_photo_cubit.dart';

@RoutePage()
class TakePhotoPage
    extends BaseStatefulPage<TakePhotoCubit, TakePhotoState, TakePhotoEvent> {
  const TakePhotoPage({super.key});

  @override
  State<StatefulWidget> createState() => _TakePhotoPageState();
}

class _TakePhotoPageState extends BaseStatefulPageState<TakePhotoPage,
    TakePhotoCubit, TakePhotoState, TakePhotoEvent> {
  late final AppCameraController _camera;

  @override
  void onWidgetCreated() {
    _camera = AppCameraController();
    _camera.initialize();
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  @override
  void onEventEmitted(TakePhotoEvent event) {
    switch (event.type) {
      case TakePhotoEventType.onShowTakenPhoto:
        _showTakenPhotoBottomSheet(context, cubit().states);
        break;
      case TakePhotoEventType.openResultScreen:
        break;
    }
  }

  @override
  Widget onWidgetBuild(BuildContext context, TakePhotoState state) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AppCameraView(
        controller: _camera,
        overlay: Align(
          alignment: Alignment.bottomCenter,
          child: _buildShutterButton(),
        ),
      ),
    );
  }

  Widget _buildShutterButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 64),
      child: InkWell(
        onTap: _onTakePhoto,
        borderRadius: BorderRadius.circular(360),
        child: Container(
          height: 64,
          width: 64,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Colors.white),
            borderRadius: BorderRadius.circular(360),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(360),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onTakePhoto() async {
    HapticFeedback.heavyImpact();

    final photo = await _camera.takePicture();
    if (photo == null) return;

    final bytes = await photo.readAsBytes();
    final photoInBase64 = await _cropImage(bytes);
    if (!mounted) return;

    cubit().setTakenPhoto(photo, photoInBase64);
    cubit().showPicture();
  }

  /// Crops the capture to the 3:4 frame the preview shows and returns it as
  /// base64, ready for the confirmation sheet.
  Future<String> _cropImage(Uint8List originalImageBytes) async {
    final lokiimage.Image? originalImage =
        lokiimage.decodeImage(originalImageBytes);
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

    return base64Encode(lokiimage.encodeJpg(croppedImage));
  }

  void _showTakenPhotoBottomSheet(BuildContext context, TakePhotoState state) {
    showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (BuildContext modalContext) {
        return Material(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              BottomSheetTitle(title: Strings.takeAttPreview),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Strings.takeAttCheckImageBeforeSending
                    .s(16)
                    .w(500)
                    .copyWith(textAlign: TextAlign.center),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  base64Decode(state.takenPhotoInBase64),
                  fit: BoxFit.cover,
                  height: 400,
                  width: 300,
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(height: 24),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomElevatedButton(
                  text: Strings.commonRetakePhoto,
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Navigator.of(modalContext).pop();
                  },
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomElevatedButton(
                  text: Strings.commonApply,
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Navigator.of(modalContext).pop();
                    context.router.push(
                      ChatRoute(
                        photoFile: state.takenPhotoFile!,
                        type: DescribeImgType.question,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
