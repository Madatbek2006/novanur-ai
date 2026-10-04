import 'dart:typed_data';
import 'dart:ui';

/// An image that is ready for analysis: an upright JPEG and its pixel size.
class BrowserImage {
  final Uint8List bytes;
  final int width;
  final int height;
  final String name;

  const BrowserImage({
    required this.bytes,
    required this.width,
    required this.height,
    required this.name,
  });

  Size get size => Size(width.toDouble(), height.toDouble());
}

/// A file the user picked, dropped or pasted, as the browser handed it over.
class PickedFileData {
  final String name;
  final String type;
  final Uint8List bytes;

  const PickedFileData({
    required this.name,
    required this.type,
    required this.bytes,
  });
}

enum BrowserCameraStatus {
  /// Permission already given, the camera can start without a prompt.
  granted,

  /// The browser will ask for permission on start.
  prompt,
  denied,

  /// No camera attached.
  none,

  /// Page is not served over HTTPS (or localhost), so the browser hides cameras.
  insecure,
  unsupported,

  /// Another app holds the camera.
  busy,
  error;

  static BrowserCameraStatus parse(String? value) => BrowserCameraStatus.values
      .firstWhere((e) => e.name == value, orElse: () => BrowserCameraStatus.error);

  bool get canStart =>
      this == BrowserCameraStatus.granted || this == BrowserCameraStatus.prompt;
}

class CameraStartResult {
  final BrowserCameraStatus? error;
  final Size videoSize;
  final int cameras;

  const CameraStartResult({this.error, this.videoSize = Size.zero, this.cameras = 0});

  bool get ok => error == null;
}

class VisionBarcode {
  final String text;
  final String format;

  const VisionBarcode({required this.text, required this.format});

  /// EAN/UPC style codes are what Open Food Facts can look up.
  bool get isProductCode => RegExp(r'^\d{8,14}$').hasMatch(text);

  @override
  bool operator ==(Object other) =>
      other is VisionBarcode && other.text == text && other.format == format;

  @override
  int get hashCode => Object.hash(text, format);
}

class VisionObject {
  /// English COCO class name, as the detector reports it.
  final String label;
  final double score;

  /// In the analysed image's pixel coordinates.
  final Rect box;

  const VisionObject({required this.label, required this.score, required this.box});
}

class VisionObjects {
  final Size imageSize;
  final List<VisionObject> objects;

  const VisionObjects({required this.imageSize, required this.objects});

  static const empty = VisionObjects(imageSize: Size.zero, objects: []);
}
