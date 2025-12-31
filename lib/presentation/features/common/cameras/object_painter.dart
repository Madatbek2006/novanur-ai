import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class ObjectPainter extends CustomPainter {
  final List<DetectedObject> objects;
  final Size previewSize;

  ObjectPainter({
    required this.objects,
    required this.previewSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / previewSize.height;
    final scaleY = size.height / previewSize.width;

    final paintRect = Paint()
      ..color = const Color.fromARGB(255, 0, 255, 0)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final textStyle = TextStyle(
      color: const Color.fromARGB(255, 0, 255, 0),
      fontSize: 16,
    );

    for (final obj in objects) {
      final rect = Rect.fromLTRB(
        obj.boundingBox.left * scaleX,
        obj.boundingBox.top * scaleY,
        obj.boundingBox.right * scaleX,
        obj.boundingBox.bottom * scaleY,
      );

      canvas.drawRect(rect, paintRect);
      final mainLabel = obj.labels.first.text;
      // for (final label in obj.labels) {
        final textSpan = TextSpan(text: mainLabel, style: textStyle);
        final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(rect.left, rect.top - tp.height));
      // }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
