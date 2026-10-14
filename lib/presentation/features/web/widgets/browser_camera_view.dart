import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:nurnova_ai/core/platform/app_platform.dart';
import 'package:nurnova_ai/utils/web/browser_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// What to look for in the live picture.
enum LiveTask { none, barcode, objects }

/// Lets the parent take a photo from the running camera.
class BrowserCameraController {
  _CameraCapture? _state;

  Future<BrowserImage?> capture() async => _state?.capture();
}

abstract interface class _CameraCapture {
  Future<BrowserImage?> capture();
}

/// Live camera preview for the site: in a browser a <video> element fed by
/// getUserMedia, in the desktop app the camera plugin. Stops the camera when
/// it leaves the tree.
class BrowserCameraView extends StatefulWidget {
  const BrowserCameraView({
    super.key,
    required this.controller,
    required this.onStarted,
    this.front = false,
    this.liveTask = LiveTask.none,
    this.onBarcode,
    this.onObjects,
    this.onLiveError,
  });

  final BrowserCameraController controller;
  final ValueChanged<CameraStartResult> onStarted;
  final bool front;
  final LiveTask liveTask;
  final ValueChanged<VisionBarcode>? onBarcode;
  final ValueChanged<VisionObjects>? onObjects;
  final ValueChanged<Object>? onLiveError;

  @override
  State<BrowserCameraView> createState() =>
      isDesktop ? _DesktopCameraState() : _BrowserCameraViewState();
}

class _BrowserCameraViewState extends State<BrowserCameraView>
    implements _CameraCapture {
  Object? _video;
  bool _running = false;
  bool _looping = false;
  int _startCount = 0;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
  }

  @override
  void didUpdateWidget(BrowserCameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._state = null;
      widget.controller._state = this;
    }
    if (oldWidget.front != widget.front) {
      _start();
    } else if (oldWidget.liveTask != widget.liveTask) {
      _runLiveLoop();
    }
  }

  @override
  void dispose() {
    if (widget.controller._state == this) widget.controller._state = null;
    _running = false;
    final video = _video;
    if (video != null) BrowserVision.stopCamera(video);
    super.dispose();
  }

  void _onElementCreated(Object element) {
    final previous = _video;
    if (previous != null && !identical(previous, element)) {
      BrowserVision.stopCamera(previous);
    }
    _video = element;
    BrowserVision.prepareVideo(element);
    _start();
  }

  Future<void> _start() async {
    final video = _video;
    if (video == null) return;
    final attempt = ++_startCount;
    _running = false;
    final result = await BrowserVision.startCamera(video, front: widget.front);
    if (!mounted) {
      // Disposed while the browser was asking for permission.
      BrowserVision.stopCamera(video);
      return;
    }
    if (attempt != _startCount) return;
    _running = result.ok;
    widget.onStarted(result);
    _runLiveLoop();
  }

  @override
  Future<BrowserImage?> capture() async {
    final video = _video;
    if (video == null || !_running) return null;
    return BrowserVision.captureFrame(video);
  }

  Future<void> _runLiveLoop() async {
    if (_looping) return;
    _looping = true;
    try {
      while (mounted && _running && widget.liveTask != LiveTask.none) {
        final video = _video!;
        final began = DateTime.now();
        switch (widget.liveTask) {
          case LiveTask.barcode:
            final barcode = await BrowserVision.decodeBarcodeFromVideo(video);
            if (barcode != null && mounted && widget.liveTask == LiveTask.barcode) {
              widget.onBarcode?.call(barcode);
            }
          case LiveTask.objects:
            final objects = await BrowserVision.detectObjectsInVideo(video);
            if (objects != null && mounted && widget.liveTask == LiveTask.objects) {
              widget.onObjects?.call(objects);
            }
          case LiveTask.none:
            break;
        }
        // About six passes a second keeps slower machines responsive.
        final spent = DateTime.now().difference(began).inMilliseconds;
        await Future<void>.delayed(Duration(milliseconds: math.max(40, 160 - spent)));
      }
    } catch (e) {
      if (mounted) widget.onLiveError?.call(e);
    } finally {
      _looping = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: HtmlElementView.fromTagName(
        tagName: 'video',
        hitTestBehavior: PlatformViewHitTestBehavior.transparent,
        onElementCreated: _onElementCreated,
      ),
    );
  }
}

/// Камера в десктопной версии — плагин camera (на Windows camera_windows).
/// Потока кадров у него нет, поэтому живой режим работает снимками: раз в
/// полсекунды снимок, и по нему — штрихкод или предметы.
class _DesktopCameraState extends State<BrowserCameraView>
    implements _CameraCapture {
  CameraController? _camera;
  bool _looping = false;
  int _startCount = 0;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
    _start();
  }

  @override
  void didUpdateWidget(BrowserCameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._state = null;
      widget.controller._state = this;
    }
    if (oldWidget.front != widget.front) {
      _start();
    } else if (oldWidget.liveTask != widget.liveTask) {
      _runLiveLoop();
    }
  }

  @override
  void dispose() {
    if (widget.controller._state == this) widget.controller._state = null;
    _startCount++; // незавершённый запуск больше не нужен
    _camera?.dispose();
    _camera = null;
    super.dispose();
  }

  Future<void> _start() async {
    final attempt = ++_startCount;
    final previous = _camera;
    if (previous != null) {
      setState(() => _camera = null);
      await previous.dispose();
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted && attempt == _startCount) {
          widget.onStarted(const CameraStartResult(error: BrowserCameraStatus.none));
        }
        return;
      }
      final lens = widget.front ? CameraLensDirection.front : CameraLensDirection.back;
      final description =
          cameras.firstWhere((c) => c.lensDirection == lens, orElse: () => cameras.first);
      final camera = CameraController(description, ResolutionPreset.high, enableAudio: false);
      await camera.initialize();
      if (!mounted || attempt != _startCount) {
        await camera.dispose();
        return;
      }
      setState(() => _camera = camera);
      widget.onStarted(CameraStartResult(
        videoSize: camera.value.previewSize ?? Size.zero,
        cameras: cameras.length,
      ));
      _runLiveLoop();
    } on CameraException catch (e) {
      if (mounted && attempt == _startCount) {
        widget.onStarted(CameraStartResult(error: _statusFor(e)));
      }
    } catch (_) {
      // Камеры под эту систему нет вовсе — так на маке, где десктопный код
      // только проверяется.
      if (mounted && attempt == _startCount) {
        widget.onStarted(const CameraStartResult(error: BrowserCameraStatus.unsupported));
      }
    }
  }

  BrowserCameraStatus _statusFor(CameraException e) {
    final code = '${e.code} ${e.description}'.toLowerCase();
    if (code.contains('denied') || code.contains('permission') || code.contains('access')) {
      return BrowserCameraStatus.denied;
    }
    if (code.contains('busy') || code.contains('in use')) return BrowserCameraStatus.busy;
    return BrowserCameraStatus.error;
  }

  /// Снимок с камеры как есть — JPEG.
  Future<Uint8List?> _shot() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized || camera.value.isTakingPicture) {
      return null;
    }
    final file = await camera.takePicture();
    final bytes = await file.readAsBytes();
    // Каждый снимок — файл во временной папке, а живой режим наделал бы их
    // сотни за минуту.
    try {
      await File(file.path).delete();
    } catch (_) {}
    return bytes;
  }

  @override
  Future<BrowserImage?> capture() async {
    final bytes = await _shot();
    if (bytes == null) return null;
    return BrowserVision.normalizeImage(bytes, name: 'camera.jpg');
  }

  Future<void> _runLiveLoop() async {
    if (_looping) return;
    _looping = true;
    try {
      while (mounted && _camera != null && widget.liveTask != LiveTask.none) {
        final began = DateTime.now();
        final task = widget.liveTask;
        final bytes = await _shot();
        if (bytes != null && mounted && widget.liveTask == task) {
          switch (task) {
            case LiveTask.barcode:
              final barcode = await BrowserVision.decodeBarcodeFromImage(bytes);
              if (barcode != null && mounted && widget.liveTask == task) {
                widget.onBarcode?.call(barcode);
              }
            case LiveTask.objects:
              final objects = await BrowserVision.detectObjectsInImage(bytes);
              if (mounted && widget.liveTask == task) widget.onObjects?.call(objects);
            case LiveTask.none:
              break;
          }
        }
        final spent = DateTime.now().difference(began).inMilliseconds;
        await Future<void>.delayed(Duration(milliseconds: math.max(100, 500 - spent)));
      }
    } catch (e) {
      if (mounted) widget.onLiveError?.call(e);
    } finally {
      _looping = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final camera = _camera;
    final size = camera?.value.previewSize;
    return ColoredBox(
      color: Colors.black,
      child: camera == null || size == null || !camera.value.isInitialized
          ? const SizedBox.expand()
          // Как у видео на сайте: кадр целиком, по краям поля — на этот же
          // прямоугольник ложатся рамки предметов.
          : FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: CameraPreview(camera),
              ),
            ),
    );
  }
}
