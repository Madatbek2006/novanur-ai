import 'dart:async';
import 'dart:math' as math;

import 'package:nurnova_ai/utils/web/browser_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// What to look for in the live picture.
enum LiveTask { none, barcode, objects }

/// Lets the parent take a photo from the running camera.
class BrowserCameraController {
  _BrowserCameraViewState? _state;

  Future<BrowserImage?> capture() async => _state?._capture();
}

/// Live camera preview for the web build: a <video> element fed by
/// getUserMedia. Stops the camera when it leaves the tree.
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
  State<BrowserCameraView> createState() => _BrowserCameraViewState();
}

class _BrowserCameraViewState extends State<BrowserCameraView> {
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

  Future<BrowserImage?> _capture() async {
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
