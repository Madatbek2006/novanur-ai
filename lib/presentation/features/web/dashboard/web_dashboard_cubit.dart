import 'dart:async';
import 'dart:ui';

import 'package:baiqavisit/core/enum/describe_img_type.dart';
import 'package:baiqavisit/core/enum/enums.dart';
import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/data/datasource/network/dto/barcode/product_response.dart';
import 'package:baiqavisit/data/repositories/photo_analysis_repository.dart';
import 'package:baiqavisit/domain/models/dashboard/dashboard_button_data.dart';
import 'package:baiqavisit/presentation/support/cubit/base_cubit.dart';
import 'package:baiqavisit/utils/web/browser_vision.dart';
import 'package:baiqavisit/utils/web/coco_labels.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'web_dashboard_cubit.freezed.dart';
part 'web_dashboard_state.dart';

/// Drives the browser dashboard: one image (picked, dropped, pasted or taken
/// with the camera) analysed by whichever of the four tools is selected.
class WebDashboardCubit extends BaseCubit<WebDashboardState, WebDashboardEvent> {
  WebDashboardCubit(this._photoAnalysisRepository)
      : super(const WebDashboardState()) {
    _tts.setCompletionHandler(_onSpeechDone);
    _tts.setCancelHandler(_onSpeechDone);
    _tts.setErrorHandler((_) => _onSpeechDone());
  }

  final PhotoAnalysisRepository _photoAnalysisRepository;
  final FlutterTts _tts = FlutterTts();

  String _languageCode = 'uz';

  // Bumped whenever the image changes, so results of stale work are dropped.
  int _imageVersion = 0;
  int _openAttempt = 0;
  String? _lastLiveBarcode;
  DateTime _lastLiveBarcodeAt = DateTime(0);
  bool _cameraPaused = false;
  // Until the user picks a text language, it follows the app language.
  bool _ocrLanguageChosen = false;

  @override
  Future<void> close() async {
    await _tts.stop();
    return super.close();
  }

  Future<void> init(Locale locale) async {
    await setLocale(locale);
    final camera = await BrowserVision.cameraStatus();
    updateState((state) => state.copyWith(
          cameraStatus: camera.status,
          cameraCount: camera.cameras,
        ));
    // Visitors who already allowed the camera get it straight away.
    if (camera.status == BrowserCameraStatus.granted &&
        states.source == WebImageSource.none) {
      await useCamera();
    }
    BrowserVision.preload(_preloadKey(states.mode));
  }

  Future<void> setLocale(Locale locale) async {
    _languageCode = locale.languageCode;
    if (!_ocrLanguageChosen) {
      updateState((state) => state.copyWith(ocrLanguage: OcrLanguage.forLocale(locale)));
    }
    final labels = await CocoLabels.load(locale.languageCode);
    updateState((state) => state.copyWith(labels: labels));
  }

  /// The dashboard tab was hidden: release the camera.
  void pause() {
    _cameraPaused = states.isCameraOn;
    if (_cameraPaused) stopCamera();
    stopSpeaking();
  }

  void resume() {
    if (_cameraPaused && states.source == WebImageSource.none) useCamera();
    _cameraPaused = false;
  }

  // ------------------------------------------------------------------ modes

  void selectMode(DashboardButtonType mode) {
    if (mode == states.mode) return;
    stopSpeaking();
    updateState((state) => state.copyWith(mode: mode));
    BrowserVision.preload(_preloadKey(mode));
    if (states.isCameraOn) {
      // Live tools start from a clean slate; the overlay of the old tool goes.
      updateState((state) => state.copyWith(
            objects: VisionObjects.empty,
            objectsState: mode == DashboardButtonType.objectRecognition
                ? LoadingState.loading
                : LoadingState.initial,
          ));
    } else if (states.hasImage) {
      _analyzeIfNeeded();
    }
  }

  String _preloadKey(DashboardButtonType mode) => switch (mode) {
        DashboardButtonType.scanText => 'text:${states.ocrLanguage.tesseractCodes}',
        DashboardButtonType.scanBarcode => 'barcode',
        DashboardButtonType.objectRecognition => 'objects',
        DashboardButtonType.describeScene => '',
      };

  // ----------------------------------------------------------------- images

  void setDragging(bool dragging) {
    if (dragging != states.isDragging) {
      updateState((state) => state.copyWith(isDragging: dragging));
    }
  }

  Future<void> openFile(PickedFileData? file) async {
    if (file == null) {
      updateState((state) => state.copyWith(sourceError: Strings.webImageUnsupported));
      return;
    }
    final attempt = ++_openAttempt;
    updateState((state) => state.copyWith(isOpeningImage: true, sourceError: null));
    try {
      final image = await BrowserVision.normalizeImage(file.bytes, name: file.name);
      // A newer file or a camera photo arrived while this one was decoding.
      if (attempt != _openAttempt) return;
      setImage(image);
    } catch (e) {
      logger.w("openFile failed: $e");
      if (attempt != _openAttempt) return;
      updateState((state) => state.copyWith(sourceError: Strings.webImageUnsupported));
    } finally {
      if (attempt == _openAttempt) {
        updateState((state) => state.copyWith(isOpeningImage: false));
      }
    }
  }

  void clearSourceError() => updateState((state) => state.copyWith(sourceError: null));

  void setImage(BrowserImage image) {
    _openAttempt++;
    _imageVersion++;
    stopSpeaking();
    updateState((state) => state.copyWith(
          source: WebImageSource.image,
          image: image,
          isOpeningImage: false,
          sourceError: null,
          textState: LoadingState.initial,
          recognizedText: "",
          ocrStatus: "",
          ocrProgress: 0,
          barcodeState: LoadingState.initial,
          barcode: null,
          productState: LoadingState.initial,
          product: null,
          objectsState: LoadingState.initial,
          objects: VisionObjects.empty,
          describeType: null,
        ));
    _analyzeIfNeeded();
  }

  void removeImage() {
    _imageVersion++;
    stopSpeaking();
    updateState((state) => state.copyWith(
          source: WebImageSource.none,
          image: null,
          textState: LoadingState.initial,
          recognizedText: "",
          barcodeState: LoadingState.initial,
          barcode: null,
          productState: LoadingState.initial,
          product: null,
          objectsState: LoadingState.initial,
          objects: VisionObjects.empty,
          describeType: null,
        ));
  }

  // ----------------------------------------------------------------- camera

  Future<void> useCamera() async {
    // Ask again: the user may have plugged in a camera or changed site settings.
    final camera = await BrowserVision.cameraStatus();
    updateState((state) => state.copyWith(
          cameraStatus: camera.status,
          cameraCount: camera.cameras,
        ));
    if (!camera.status.canStart) {
      updateState((state) => state.copyWith(sourceError: _cameraMessage(camera.status)));
      return;
    }
    _openAttempt++;
    _imageVersion++;
    stopSpeaking();
    updateState((state) => state.copyWith(
          source: WebImageSource.camera,
          image: null,
          isOpeningImage: false,
          sourceError: null,
          barcodeState: LoadingState.initial,
          barcode: null,
          productState: LoadingState.initial,
          product: null,
          objects: VisionObjects.empty,
          objectsState: state.mode == DashboardButtonType.objectRecognition
              ? LoadingState.loading
              : LoadingState.initial,
          describeType: null,
        ));
  }

  void cameraStarted(CameraStartResult result) {
    if (!states.isCameraOn) return;
    if (result.ok) {
      updateState((state) => state.copyWith(
            cameraStatus: BrowserCameraStatus.granted,
            cameraCount: result.cameras,
          ));
      return;
    }
    final status = result.error!;
    updateState((state) => state.copyWith(
          source: WebImageSource.none,
          // "busy" and "error" can pass, so trying again stays possible.
          cameraStatus: status == BrowserCameraStatus.busy || status == BrowserCameraStatus.error
              ? BrowserCameraStatus.prompt
              : status,
          sourceError: _cameraMessage(status),
        ));
  }

  void switchCamera() {
    updateState((state) => state.copyWith(isFrontCamera: !state.isFrontCamera));
  }

  void stopCamera() {
    if (!states.isCameraOn) return;
    updateState((state) => state.copyWith(
          source: WebImageSource.none,
          objects: VisionObjects.empty,
          objectsState: LoadingState.initial,
        ));
  }

  String _cameraMessage(BrowserCameraStatus status) => switch (status) {
        BrowserCameraStatus.none => Strings.webCameraNoDevice,
        BrowserCameraStatus.denied => Strings.webCameraDenied,
        BrowserCameraStatus.insecure => Strings.webCameraInsecure,
        BrowserCameraStatus.unsupported => Strings.webCameraUnsupported,
        BrowserCameraStatus.busy => Strings.webCameraBusy,
        _ => Strings.webCameraError,
      };

  // ---------------------------------------------------------------- analysis

  void _analyzeIfNeeded() {
    if (!states.hasImage) return;
    switch (states.mode) {
      case DashboardButtonType.scanText:
        if (states.textState == LoadingState.initial) recognizeText();
      case DashboardButtonType.scanBarcode:
        if (states.barcodeState == LoadingState.initial) decodeBarcode();
      case DashboardButtonType.objectRecognition:
        if (states.objectsState == LoadingState.initial) detectObjects();
      case DashboardButtonType.describeScene:
        break; // waits for the user to pick the kind of description
    }
  }

  Future<void> recognizeText() async {
    final image = states.image;
    if (image == null) return;
    final version = _imageVersion;
    stopSpeaking();
    updateState((state) => state.copyWith(
          textState: LoadingState.loading,
          recognizedText: "",
          ocrStatus: "",
          ocrProgress: 0,
        ));
    try {
      final text = await BrowserVision.recognizeText(
        image.bytes,
        states.ocrLanguage.tesseractCodes,
        (status, progress) {
          if (version != _imageVersion) return;
          updateState((state) => state.copyWith(ocrStatus: status, ocrProgress: progress));
        },
      );
      if (version != _imageVersion) return;
      final cleaned = text.trim();
      updateState((state) => state.copyWith(
            recognizedText: cleaned,
            textState: cleaned.isEmpty ? LoadingState.empty : LoadingState.success,
          ));
    } catch (e) {
      logger.w("recognizeText failed: $e");
      if (version != _imageVersion) return;
      updateState((state) => state.copyWith(textState: LoadingState.error));
    }
  }

  void setOcrLanguage(OcrLanguage language) {
    _ocrLanguageChosen = true;
    if (language == states.ocrLanguage) return;
    updateState((state) => state.copyWith(ocrLanguage: language));
    if (states.hasImage && states.mode == DashboardButtonType.scanText) {
      recognizeText();
    } else {
      BrowserVision.preload('text:${language.tesseractCodes}');
    }
  }

  Future<void> decodeBarcode() async {
    final image = states.image;
    if (image == null) return;
    final version = _imageVersion;
    updateState((state) => state.copyWith(
          barcodeState: LoadingState.loading,
          barcode: null,
          productState: LoadingState.initial,
          product: null,
        ));
    try {
      final barcode = await BrowserVision.decodeBarcodeFromImage(image.bytes);
      if (version != _imageVersion) return;
      if (barcode == null) {
        updateState((state) => state.copyWith(barcodeState: LoadingState.empty));
        return;
      }
      updateState((state) => state.copyWith(barcodeState: LoadingState.success, barcode: barcode));
      await _lookUpProduct(barcode, version: version);
    } catch (e) {
      logger.w("decodeBarcode failed: $e");
      if (version != _imageVersion) return;
      updateState((state) => state.copyWith(barcodeState: LoadingState.error));
    }
  }

  /// A code typed in by hand, for when there is neither camera nor photo.
  Future<void> searchBarcode(String text) async {
    final code = text.replaceAll(RegExp(r'\s'), '');
    if (code.isEmpty) return;
    final barcode = VisionBarcode(text: code, format: '');
    updateState((state) => state.copyWith(barcodeState: LoadingState.success, barcode: barcode));
    await _lookUpProduct(barcode, version: _imageVersion);
  }

  void onLiveBarcode(VisionBarcode barcode) {
    final now = DateTime.now();
    final repeated = barcode.text == _lastLiveBarcode &&
        now.difference(_lastLiveBarcodeAt) < const Duration(seconds: 5);
    if (repeated || states.productState == LoadingState.loading) return;
    _lastLiveBarcode = barcode.text;
    _lastLiveBarcodeAt = now;
    HapticFeedback.mediumImpact();
    updateState((state) => state.copyWith(barcodeState: LoadingState.success, barcode: barcode));
    _lookUpProduct(barcode, version: _imageVersion);
  }

  Future<void> _lookUpProduct(VisionBarcode barcode, {required int version}) async {
    if (!barcode.isProductCode) {
      // A QR code with a link or text: reading it out is the useful part.
      updateState((state) => state.copyWith(productState: LoadingState.initial, product: null));
      speak(barcode.text);
      return;
    }
    updateState((state) => state.copyWith(productState: LoadingState.loading, product: null));
    try {
      final product = await _photoAnalysisRepository.getProduct(barcode.text);
      if (version != _imageVersion || states.barcode != barcode) return;
      final name = product?.productName?.trim() ?? '';
      updateState((state) => state.copyWith(
            product: product,
            productState: name.isEmpty ? LoadingState.empty : LoadingState.success,
          ));
      // Same as the phone app: say what the product is.
      speak(name.isEmpty ? Strings.commonProductNotFound : name);
    } catch (e) {
      logger.w("product lookup failed: $e");
      if (version != _imageVersion || states.barcode != barcode) return;
      updateState((state) => state.copyWith(productState: LoadingState.error));
    }
  }

  Future<void> detectObjects() async {
    final image = states.image;
    if (image == null) return;
    final version = _imageVersion;
    updateState((state) => state.copyWith(
          objectsState: LoadingState.loading,
          objects: VisionObjects.empty,
        ));
    try {
      final objects = await BrowserVision.detectObjectsInImage(image.bytes);
      if (version != _imageVersion) return;
      updateState((state) => state.copyWith(
            objects: objects,
            objectsState: objects.objects.isEmpty ? LoadingState.empty : LoadingState.success,
          ));
    } catch (e) {
      logger.w("detectObjects failed: $e");
      if (version != _imageVersion) return;
      updateState((state) => state.copyWith(objectsState: LoadingState.error));
    }
  }

  void onLiveObjects(VisionObjects objects) {
    if (!states.isCameraOn || states.mode != DashboardButtonType.objectRecognition) return;
    updateState((state) => state.copyWith(
          objects: objects,
          objectsState: objects.objects.isEmpty ? LoadingState.empty : LoadingState.success,
        ));
  }

  void onLiveError(Object error) {
    logger.w("live analysis failed: $error");
    switch (states.mode) {
      case DashboardButtonType.objectRecognition:
        updateState((state) => state.copyWith(objectsState: LoadingState.error));
      case DashboardButtonType.scanBarcode:
        updateState((state) => state.copyWith(barcodeState: LoadingState.error));
      default:
        break;
    }
  }

  /// Re-runs the current tool, e.g. after a network error.
  void retry() {
    if (states.hasImage) {
      switch (states.mode) {
        case DashboardButtonType.scanText:
          recognizeText();
        case DashboardButtonType.scanBarcode:
          decodeBarcode();
        case DashboardButtonType.objectRecognition:
          detectObjects();
        case DashboardButtonType.describeScene:
          break;
      }
    } else if (states.isCameraOn) {
      // The camera view restarts its live loop when the state leaves "error".
      updateState((state) => state.copyWith(
            objectsState: state.mode == DashboardButtonType.objectRecognition
                ? LoadingState.loading
                : state.objectsState,
            barcodeState: state.mode == DashboardButtonType.scanBarcode
                ? LoadingState.initial
                : state.barcodeState,
          ));
    }
  }

  // --------------------------------------------------------------- describe

  void startDescribing(DescribeImgType type) {
    updateState((state) => state.copyWith(
          describeType: type,
          chatSession: state.chatSession + 1,
        ));
  }

  void resetDescribing() {
    updateState((state) => state.copyWith(describeType: null));
  }

  // ------------------------------------------------------------------ voice

  Future<void> speak(String text, {String? languageCode}) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    // Browsers load voices lazily, so pick one right before speaking.
    await _tts.setLanguage(languageCode ?? _languageCode);
    updateState((state) => state.copyWith(isSpeaking: true));
    await _tts.speak(text);
  }

  void speakRecognizedText() => speak(
        states.recognizedText,
        languageCode: switch (states.ocrLanguage) {
          OcrLanguage.uzbek => 'uz',
          OcrLanguage.russian => 'ru',
          OcrLanguage.english => 'en',
        },
      );

  void stopSpeaking() {
    if (!states.isSpeaking) return;
    _tts.stop();
    updateState((state) => state.copyWith(isSpeaking: false));
  }

  void _onSpeechDone() {
    if (isClosed) return;
    updateState((state) => state.copyWith(isSpeaking: false));
  }

  void textCopied() => emitEvent(const WebDashboardEvent(WebDashboardEventType.textCopied));
}
