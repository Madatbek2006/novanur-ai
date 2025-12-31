// import 'dart:io';
// import 'dart:typed_data';
// import 'package:camera/camera.dart';
// import 'package:image/image.dart' as img;
// import 'package:path_provider/path_provider.dart';
//
// Future<File> convertYUV420ToJpeg(XFile yuvFile) async {
//   final bytes = await yuvFile.readAsBytes();
//   final cameraImage = _parseCameraImage(bytes); // Это твой метод парсинга в CameraImage
//   final jpegData = _yuvToJpeg(cameraImage);
//
//   final dir = await getTemporaryDirectory();
//   final jpegFile = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
//   await jpegFile.writeAsBytes(jpegData);
//
//   return jpegFile;
// }
//
// // Пример YUV -> JPEG
// Uint8List _yuvToJpeg(CameraImage image) {
//   final img.Image rgbImage = img.Image.fromBytes(
//     width: image.width, height: image.height, bytes: _convertYUV420toRGB(image),
//   );
//   return Uint8List.fromList(img.encodeJpg(rgbImage));
// }
//
// Uint8List _convertYUV420toRGB(CameraImage image) {
//   final int width = image.width;
//   final int height = image.height;
//   final int uvRowStride = image.planes[1].bytesPerRow;
//   final int uvPixelStride = image.planes[1].bytesPerPixel!;
//   final Uint8List rgb = Uint8List(width * height * 3);
//
//   for (int y = 0; y < height; y++) {
//     final int uvRow = uvRowStride * (y >> 1);
//     for (int x = 0; x < width; x++) {
//       final int uvIndex = uvRow + (x >> 1) * uvPixelStride;
//       final int yp = image.planes[0].bytes[y * image.planes[0].bytesPerRow + x];
//       final int up = image.planes[1].bytes[uvIndex];
//       final int vp = image.planes[2].bytes[uvIndex];
//       int r = (yp + vp * 1436 / 1024 - 179).clamp(0, 255).toInt();
//       int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).clamp(0, 255).toInt();
//       int b = (yp + up * 1814 / 1024 - 227).clamp(0, 255).toInt();
//       final int index = (y * width + x) * 3;
//       rgb[index] = r;
//       rgb[index + 1] = g;
//       rgb[index + 2] = b;
//     }
//   }
//   return rgb;
// }
