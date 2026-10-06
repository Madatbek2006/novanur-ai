import 'dart:math' as math;

import 'package:nurnova_ai/core/gen/assets/fonts.gen.dart';
import 'package:nurnova_ai/utils/web/browser_vision.dart';
import 'package:flutter/material.dart';

/// Draws detected objects over an image or video shown with BoxFit.contain.
class DetectionsPainter extends CustomPainter {
  DetectionsPainter({required this.result, required this.nameOf});

  final VisionObjects result;
  final String Function(String label) nameOf;

  static const _palette = [
    Color(0xFF00C853),
    Color(0xFF2979FF),
    Color(0xFFFFAB00),
    Color(0xFFFF4081),
    Color(0xFF00B8D4),
    Color(0xFFAA00FF),
    Color(0xFFFF6D00),
    Color(0xFF64DD17),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final imageSize = result.imageSize;
    if (imageSize.isEmpty || result.objects.isEmpty) return;
    final fitted = applyBoxFit(BoxFit.contain, imageSize, size);
    final frame = Alignment.center.inscribe(fitted.destination, Offset.zero & size);
    final scale = frame.width / imageSize.width;

    for (final object in result.objects) {
      final color = _palette[object.label.hashCode.abs() % _palette.length];
      final box = Rect.fromLTWH(
        frame.left + object.box.left * scale,
        frame.top + object.box.top * scale,
        object.box.width * scale,
        object.box.height * scale,
      ).intersect(frame);
      if (box.isEmpty) continue;

      canvas.drawRRect(
        RRect.fromRectAndRadius(box, const Radius.circular(6)),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      final label = TextPainter(
        text: TextSpan(
          text: '${nameOf(object.label)} ${(object.score * 100).round()}%',
          style: const TextStyle(
            // A painter has no ambient text style to inherit the app font from.
            fontFamily: FontFamily.inter,
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: math.max(box.width, 120));
      final chipTop = box.top - label.height - 6 >= frame.top ? box.top - label.height - 6 : box.top;
      final chip = Rect.fromLTWH(box.left, chipTop, label.width + 12, label.height + 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(chip, const Radius.circular(4)),
        Paint()..color = color,
      );
      label.paint(canvas, chip.topLeft + const Offset(6, 3));
    }
  }

  @override
  bool shouldRepaint(DetectionsPainter oldDelegate) =>
      oldDelegate.result != result || oldDelegate.nameOf != nameOf;
}
