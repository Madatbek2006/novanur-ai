import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:logger/logger.dart';
import 'package:nurnova_ai/core/extensions/list_extensions.dart';
import 'package:nurnova_ai/presentation/application/manager/object_detection_manager.dart';
import 'package:nurnova_ai/presentation/support/extensions/compressing_exts.dart';
import 'package:permission_handler/permission_handler.dart';

/// What the shared camera stream is analysed for.
///
/// Switching analysis does **not** reopen the camera — only the consumer of the
/// frames changes. That is what keeps mode switching on the dashboard instant
/// and guarantees there is never more than one open camera.
enum CameraAnalysis { none, objectDetection, barcode }

enum CameraStatus {
  idle,
  initializing,
  ready,
  permissionDenied,
  unavailable,
  error,
}

/// The app's single camera.
///
/// Owns the one and only [CameraController]. Screens that need a camera create
/// an instance of this class and render an `AppCameraView` bound to it, instead
/// of opening a controller of their own.
class AppCameraController extends ChangeNotifier with WidgetsBindingObserver {
  AppCameraController({
    this.resolution = ResolutionPreset.high,
    this.onBarcode,
  });

  final ResolutionPreset resolution;

  /// Invoked once per newly seen barcode while [CameraAnalysis.barcode] is on.
  final void Function(String value)? onBarcode;

  CameraController? _camera;
  CameraDescription? _description;
  BarcodeScanner? _barcodeScanner;

  CameraStatus _status = CameraStatus.idle;
  CameraAnalysis _analysis = CameraAnalysis.none;
  List<DetectedObject> _objects = const <DetectedObject>[];
  Object? _error;

  bool _analysing = false;
  bool _streaming = false;
  bool _disposed = false;
  String? _lastBarcode;

  CameraController? get camera => _camera;

  CameraStatus get status => _status;

  CameraAnalysis get analysis => _analysis;

  List<DetectedObject> get objects => _objects;

  Object? get error => _error;

  bool get isReady =>
      _status == CameraStatus.ready && (_camera?.value.isInitialized ?? false);

  /// Opens the camera. Safe to call once per screen; repeated calls are ignored
  /// while an open is already in flight.
  Future<void> initialize({CameraAnalysis analysis = CameraAnalysis.none}) async {
    if (_disposed || _status == CameraStatus.initializing) return;
    _analysis = analysis;
    WidgetsBinding.instance.addObserver(this);
    await _open();
  }

  /// Re-opens after a denied permission or a transient failure.
  Future<void> retry() => _open();

  /// Switches what frames are analysed. The camera itself keeps running.
  Future<void> setAnalysis(CameraAnalysis analysis) async {
    if (_disposed || _analysis == analysis) return;
    _analysis = analysis;
    _objects = const <DetectedObject>[];
    _lastBarcode = null;
    await _syncStream();
    _notify();
  }

  /// Captures a still frame. The analysis stream is paused for the duration of
  /// the capture and restored afterwards.
  Future<XFile?> takePicture({bool compress = true}) async {
    final camera = _camera;
    if (camera == null ||
        !camera.value.isInitialized ||
        camera.value.isTakingPicture) {
      return null;
    }

    final wasStreaming = _streaming;
    try {
      if (wasStreaming) {
        await camera.stopImageStream();
        _streaming = false;
      }
      XFile photo = await camera.takePicture();
      if (compress) photo = await photo.compressPhoto();
      return photo;
    } catch (e, s) {
      Logger().e('AppCamera: capture failed', error: e, stackTrace: s);
      return null;
    } finally {
      if (wasStreaming && !_disposed) await _syncStream();
    }
  }

  Future<void> setFlash(FlashMode mode) async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return;
    try {
      await camera.setFlashMode(mode);
    } catch (e) {
      Logger().w('AppCamera: flash mode $mode rejected: $e');
    }
  }

  // ---------------------------------------------------------------- lifecycle

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) return;
    switch (state) {
      case AppLifecycleState.resumed:
        if (_camera == null) unawaited(_open());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        unawaited(_release());
        break;
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_teardown());
    super.dispose();
  }

  Future<void> _teardown() async {
    await _release();
    await _barcodeScanner?.close();
    _barcodeScanner = null;
    await ObjectDetectionManager().dispose();
  }

  // ------------------------------------------------------------------ private

  Future<void> _open() async {
    if (_disposed) return;
    _error = null;
    _emit(CameraStatus.initializing);

    if (!await _ensurePermission()) {
      _emit(CameraStatus.permissionDenied);
      return;
    }

    try {
      _description ??= await _pickCamera();
      final description = _description;
      if (description == null) {
        _emit(CameraStatus.unavailable);
        return;
      }

      final controller = CameraController(
        description,
        resolution,
        enableAudio: false,
        // Hand ML Kit the byte layout it expects on each platform, so frames
        // need no colour-space conversion in Dart.
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();

      if (_disposed) {
        await controller.dispose();
        return;
      }

      _camera = controller;
      _emit(CameraStatus.ready);
      await _syncStream();
    } catch (e, s) {
      Logger().e('AppCamera: open failed', error: e, stackTrace: s);
      _error = e;
      _emit(CameraStatus.error);
    }
  }

  /// Closes the platform camera but leaves this controller reusable.
  Future<void> _release() async {
    final camera = _camera;
    if (camera == null) return;

    // Drop the reference first so nothing can render a disposed controller.
    _camera = null;
    _streaming = false;
    _objects = const <DetectedObject>[];
    _emit(CameraStatus.idle);

    try {
      if (camera.value.isStreamingImages) await camera.stopImageStream();
    } catch (_) {
      // Already stopped — nothing to undo.
    }
    await camera.dispose();
  }

  Future<CameraDescription?> _pickCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return null;
    final back =
        cameras.filterIf((c) => c.lensDirection == CameraLensDirection.back);
    return back.isNotEmpty ? back.first : cameras.first;
  }

  Future<bool> _ensurePermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted) return true;
    if (status.isDenied || status.isLimited) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  /// Brings the image stream in line with the active [analysis].
  Future<void> _syncStream() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return;

    final wanted = _analysis != CameraAnalysis.none;
    if (wanted == _streaming) return;

    try {
      if (wanted) {
        await _prepareAnalyser();
        await camera.startImageStream(_onFrame);
        _streaming = true;
      } else {
        await camera.stopImageStream();
        _streaming = false;
      }
    } catch (e, s) {
      Logger().e('AppCamera: stream toggle failed', error: e, stackTrace: s);
    }
  }

  Future<void> _prepareAnalyser() async {
    switch (_analysis) {
      case CameraAnalysis.objectDetection:
        if (!ObjectDetectionManager().isInitialized) {
          await ObjectDetectionManager().init();
        }
        break;
      case CameraAnalysis.barcode:
        _barcodeScanner ??= BarcodeScanner();
        break;
      case CameraAnalysis.none:
        break;
    }
  }

  /// Frames arrive faster than ML Kit can consume them, so anything that lands
  /// while an analysis is in flight is dropped rather than queued.
  Future<void> _onFrame(CameraImage image) async {
    if (_disposed || _analysing || _analysis == CameraAnalysis.none) return;
    _analysing = true;

    try {
      final input = _toInputImage(image);
      if (input == null) return;

      switch (_analysis) {
        case CameraAnalysis.objectDetection:
          final detected = await ObjectDetectionManager().detect(input);
          _objects = detected.filterIf((o) => o.labels.isNotEmpty);
          _notify();
          break;
        case CameraAnalysis.barcode:
          final codes = await _barcodeScanner!.processImage(input);
          final value =
              codes.firstIf((b) => (b.rawValue ?? '').isNotEmpty)?.rawValue;
          if (value != null && value != _lastBarcode) {
            _lastBarcode = value;
            onBarcode?.call(value);
          }
          break;
        case CameraAnalysis.none:
          break;
      }
    } catch (e) {
      Logger().w('AppCamera: frame analysis failed: $e');
    } finally {
      _analysing = false;
    }
  }

  InputImage? _toInputImage(CameraImage image) {
    final description = _description;
    if (description == null || image.planes.isEmpty) return null;

    final rotation =
        InputImageRotationValue.fromRawValue(description.sensorOrientation) ??
            InputImageRotation.rotation0deg;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: Platform.isAndroid
            ? InputImageFormat.nv21
            : InputImageFormat.bgra8888,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  void _emit(CameraStatus status) {
    _status = status;
    _notify();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }
}
