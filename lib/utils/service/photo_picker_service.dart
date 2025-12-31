import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoPickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<List<XFile>?> pickMultipleFromGallery(BuildContext context) async {
    // Запрашиваем разрешение на фото/галерею
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      return await _picker.pickMultiImage();
    } else if (status.isPermanentlyDenied) {
      bool openSettings = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Требуется разрешение'),
          content: const Text(
              'Для использования этой функции необходимо разрешение. Хотите открыть настройки приложения?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Настройки'),
            ),
          ],
        ),
      );

      if (openSettings) {
        await openAppSettings();
      }
    }

    return null;
  }


  static Future<XFile?> pickFromCamera(BuildContext context,{CropType? type}) async {
    var file= await _requestPermission(
      context,
      permission: Permission.camera,
      source: ImageSource.camera,
    );
    return await cropImage(file,type: type);



  }

  static Future<XFile?> pickFromGallery(BuildContext context,{CropType? type,
  }) async {
    var file= await _requestPermission(
      context,
      permission: Permission.photos,
      source: ImageSource.gallery,
    );
    // if(isCrop)
    return await cropImage(file,type: type);
  }

  static Future<XFile?> _requestPermission(
      BuildContext context, {
        required Permission permission,
        required ImageSource source,
      }) async {
    var status = await permission.status;

    if (!status.isGranted) {
      status = await permission.request();
    }

    if (status.isGranted) {
      return await _picker.pickImage(source: source);
    } else if (status.isPermanentlyDenied) {
      // Показываем диалог с предложением открыть настройки
      bool openSettings = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Требуется разрешение'),
          content: const Text(
              'Для использования этой функции необходимо разрешение. Хотите открыть настройки приложения?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Настройки'),
            ),
          ],
        ),
      );

      if (openSettings) {
        await openAppSettings();
      }
    }

    return null;
  }


  static Future<XFile?> cropImage(
      XFile? file, {
        CropType? type,
      }) async {
    if (file == null) return null;

    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: type != null
          ? CropAspectRatio(ratioX: type.x, ratioY: type.y)
          : null, // динамичный кроп
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Обрезка",
          lockAspectRatio: type != null,
        ),
        IOSUiSettings(
          title: "Обрезка",
          aspectRatioLockEnabled: type != null,
        ),
      ],
    );

    if (cropped != null) return XFile(cropped.path);
    return null;
  }



}


enum CropType {
  r3x4,
  r4x1,
  r1x1,
}

extension CropRatio on CropType {
  double get x {
    switch (this) {
      case CropType.r3x4: return 3;
      case CropType.r4x1: return 4;
      case CropType.r1x1: return 1;
    }
  }

  double get y {
    switch (this) {
      case CropType.r3x4: return 4;
      case CropType.r4x1: return 1;
      case CropType.r1x1: return 1;
    }
  }
}
