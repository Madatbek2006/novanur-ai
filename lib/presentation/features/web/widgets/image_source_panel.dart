import 'dart:math' as math;

import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/presentation/features/web/widgets/detections_painter.dart';
import 'package:nurnova_ai/presentation/features/web/widgets/web_ui.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/utils/web/browser_vision.dart';
import 'package:flutter/material.dart';

/// Left side of the dashboard: where the picture comes from.
///
/// Shows a drop area until there is an image, the live camera while it runs,
/// and the chosen image (with object boxes when there are any) afterwards.
class ImageSourcePanel extends StatelessWidget {
  const ImageSourcePanel({
    super.key,
    required this.cameraView,
    required this.isCameraOn,
    required this.image,
    required this.objects,
    required this.nameOf,
    required this.cameraStatus,
    required this.cameraCount,
    required this.liveHint,
    required this.isDragging,
    required this.isOpeningImage,
    required this.error,
    required this.cameraNote,
    required this.onDismissError,
    required this.onChooseImage,
    required this.onUseCamera,
    required this.onStopCamera,
    required this.onSwitchCamera,
    required this.onCapture,
    required this.onRemoveImage,
  });

  /// Built by the page, so the live callbacks reach the cubit.
  final Widget cameraView;
  final bool isCameraOn;
  final BrowserImage? image;
  final VisionObjects objects;
  final String Function(String label) nameOf;
  final BrowserCameraStatus cameraStatus;
  final int cameraCount;

  /// Shown over the live picture, e.g. "Point the camera at a barcode".
  final String? liveHint;
  final bool isDragging;
  final bool isOpeningImage;

  /// What just went wrong (unreadable file, camera refused, ...).
  final String? error;

  /// Why the camera button is off, shown with the drop area.
  final String? cameraNote;
  final VoidCallback onDismissError;
  final VoidCallback onChooseImage;
  final VoidCallback onUseCamera;
  final VoidCallback onStopCamera;
  final VoidCallback onSwitchCamera;
  final VoidCallback onCapture;
  final VoidCallback onRemoveImage;

  bool get _cameraUsable =>
      cameraStatus != BrowserCameraStatus.none &&
      cameraStatus != BrowserCameraStatus.insecure &&
      cameraStatus != BrowserCameraStatus.unsupported;

  @override
  Widget build(BuildContext context) {
    final image = this.image;
    final Widget content;
    if (isCameraOn) {
      content = _buildCamera(context);
    } else if (image != null) {
      content = _buildImage(context, image);
    } else {
      content = _DropArea(
        cameraUsable: _cameraUsable,
        message: error ?? cameraNote,
        onChooseImage: onChooseImage,
        onUseCamera: onUseCamera,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,
          if (error != null && (isCameraOn || image != null))
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: _ErrorBanner(text: error!, onClose: onDismissError),
                ),
              ),
            ),
          if (isOpeningImage)
            const ColoredBox(
              color: Color(0x88000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (isDragging) const _DropOverlay(),
        ],
      ),
    );
  }

  Widget _buildCamera(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        cameraView,
        IgnorePointer(
          child: CustomPaint(painter: DetectionsPainter(result: objects, nameOf: nameOf)),
        ),
        if (liveHint != null)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Align(alignment: Alignment.topCenter, child: _LiveHint(text: liveHint!)),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _Toolbar(
            children: [
              _ToolbarAction(
                icon: Icons.photo_camera,
                label: Strings.commonTakePhoto.trim(),
                primary: true,
                onPressed: onCapture,
              ),
              _ToolbarAction(
                icon: Icons.photo_library_outlined,
                label: Strings.webChooseImage,
                onPressed: onChooseImage,
              ),
              if (cameraCount > 1)
                _ToolbarAction(
                  icon: Icons.cameraswitch_outlined,
                  label: Strings.webSwitchCamera,
                  onPressed: onSwitchCamera,
                ),
              _ToolbarAction(
                icon: Icons.videocam_off_outlined,
                label: Strings.webStopCamera,
                onPressed: onStopCamera,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context, BrowserImage image) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: const Color(0xFF0F1115),
          child: Semantics(
            image: true,
            label: image.name,
            child: Image.memory(
              image.bytes,
              fit: BoxFit.contain,
              gaplessPlayback: true,
            ),
          ),
        ),
        IgnorePointer(
          child: CustomPaint(painter: DetectionsPainter(result: objects, nameOf: nameOf)),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _Toolbar(
            children: [
              _ToolbarAction(
                icon: Icons.photo_library_outlined,
                label: Strings.webReplaceImage,
                primary: true,
                onPressed: onChooseImage,
              ),
              if (_cameraUsable)
                _ToolbarAction(
                  icon: Icons.videocam_outlined,
                  label: Strings.webUseCamera,
                  onPressed: onUseCamera,
                ),
              _ToolbarAction(
                icon: Icons.delete_outline,
                label: Strings.webRemoveImage,
                onPressed: onRemoveImage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.text, required this.onClose});

  final String text;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Material(
        color: const Color(0xFFFFF4E5),
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 10),
              Expanded(child: text.s(14).w(500).c(const Color(0xFF41455F))),
              IconButton(
                tooltip: Strings.commonClose,
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 20, color: Color(0xFF41455F)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropArea extends StatelessWidget {
  const _DropArea({
    required this.cameraUsable,
    required this.message,
    required this.onChooseImage,
    required this.onUseCamera,
  });

  final bool cameraUsable;
  final String? message;
  final VoidCallback onChooseImage;
  final VoidCallback onUseCamera;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.buttonPrimary;
    return Container(
      color: context.cardColor,
      child: CustomPaint(
        painter: _DashedBorderPainter(color: accent.withValues(alpha: 0.45)),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_photo_alternate_outlined, size: 36, color: accent),
                  ),
                  const SizedBox(height: 16),
                  Strings.webDropTitle.s(20).w(600).c(context.textPrimary).copyWith(textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Strings.webDropSubtitle.s(14).w(400).c(context.textSecondary).copyWith(textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: onChooseImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(Strings.webChooseImage),
                      ),
                      OutlinedButton.icon(
                        onPressed: cameraUsable ? onUseCamera : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accent,
                          side: BorderSide(color: cameraUsable ? accent : context.borderStroke),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.videocam_outlined),
                        label: Text(Strings.webUseCamera),
                      ),
                    ],
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 20),
                    WebNotice(text: message!, icon: Icons.videocam_off_outlined, color: Colors.orange),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius((Offset.zero & size).deflate(8), const Radius.circular(12)));
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 14) {
        canvas.drawPath(metric.extractPath(d, math.min(d + 8, metric.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => oldDelegate.color != color;
}

class _DropOverlay extends StatelessWidget {
  const _DropOverlay();

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.buttonPrimary;
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.85),
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.file_download_outlined, size: 56, color: Colors.white),
              const SizedBox(height: 12),
              Strings.webDropRelease.s(20).w(600).c(Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveHint extends StatelessWidget {
  const _LiveHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Flexible(child: text.s(14).w(500).c(Colors.white)),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.children});

  final List<_ToolbarAction> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0x99000000)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Icons only when labels would not fit.
          final showLabels = constraints.maxWidth >= 150.0 * children.length;
          return Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [for (final child in children) child.build(context, showLabel: showLabels)],
          );
        },
      ),
    );
  }
}

/// One button of [_Toolbar].
class _ToolbarAction {
  const _ToolbarAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool primary;

  Widget build(BuildContext context, {required bool showLabel}) {
    final background = primary ? context.colors.buttonPrimary : Colors.white.withValues(alpha: 0.16);
    final style = ElevatedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: Colors.white,
      elevation: 0,
      minimumSize: const Size(48, 48),
      padding: EdgeInsets.symmetric(horizontal: showLabel ? 18 : 12, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
    return Tooltip(
      message: label,
      child: showLabel
          ? ElevatedButton.icon(onPressed: onPressed, style: style, icon: Icon(icon), label: Text(label))
          : ElevatedButton(
              onPressed: onPressed,
              style: style,
              child: Semantics(label: label, child: Icon(icon)),
            ),
    );
  }
}
