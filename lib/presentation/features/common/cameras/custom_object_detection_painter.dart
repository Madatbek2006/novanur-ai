import 'package:flutter/material.dart';
import 'custom_object_detector.dart';

class ObjectDetectionPainter extends CustomPainter {
  final List<DetectedObjectResult> objects;
  final Size previewSize;

  ObjectDetectionPainter({required this.objects, required this.previewSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.red;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final scaleX = size.width / previewSize.width;
    final scaleY = size.height / previewSize.height;

    for (final obj in objects) {
      final left = obj.rect.left * scaleX;
      final top = obj.rect.top * scaleY;
      final right = obj.rect.right * scaleX;
      final bottom = obj.rect.bottom * scaleY;

      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);

      final labelText = '${obj.label} ${(obj.confidence * 100).toStringAsFixed(0)}%';
      textPainter.text = TextSpan(
        text: labelText,
        style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      final offset = Offset(left, top - textPainter.height < 0 ? top : top - textPainter.height);
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant ObjectDetectionPainter oldDelegate) {
    return oldDelegate.objects != objects;
  }
}
