part of 'web_dashboard_cubit.dart';

enum WebImageSource { none, camera, image }

/// Tesseract language sets; Uzbek and Russian texts are often mixed.
enum OcrLanguage {
  uzbek('uzb+rus'),
  russian('rus+eng'),
  english('eng+rus');

  const OcrLanguage(this.tesseractCodes);

  final String tesseractCodes;

  String get title => switch (this) {
        OcrLanguage.uzbek => Strings.languageUzbekLatin,
        OcrLanguage.russian => Strings.languageRussianRu,
        OcrLanguage.english => Strings.languageEnglishUs,
      };

  static OcrLanguage forLocale(Locale locale) => switch (locale.languageCode) {
        'ru' => OcrLanguage.russian,
        'en' => OcrLanguage.english,
        _ => OcrLanguage.uzbek,
      };
}

@freezed
class WebDashboardState with _$WebDashboardState {
  const WebDashboardState._();

  const factory WebDashboardState({
    @Default(DashboardButtonType.scanText) DashboardButtonType mode,
//
    @Default(WebImageSource.none) WebImageSource source,
    BrowserImage? image,
    @Default(BrowserCameraStatus.prompt) BrowserCameraStatus cameraStatus,
    @Default(0) int cameraCount,
    @Default(false) bool isFrontCamera,
    @Default(false) bool isDragging,
    @Default(false) bool isOpeningImage,
    String? sourceError,
//
    @Default(OcrLanguage.uzbek) OcrLanguage ocrLanguage,
    @Default(LoadingState.initial) LoadingState textState,
    @Default("") String recognizedText,
    @Default("") String ocrStatus,
    @Default(0.0) double ocrProgress,
//
    @Default(LoadingState.initial) LoadingState barcodeState,
    VisionBarcode? barcode,
    @Default(LoadingState.initial) LoadingState productState,
    ProductResponse? product,
//
    @Default(LoadingState.initial) LoadingState objectsState,
    @Default(VisionObjects.empty) VisionObjects objects,
    CocoLabels? labels,
//
    DescribeImgType? describeType,
    @Default(0) int chatSession,
//
    @Default(false) bool isSpeaking,
  }) = _WebDashboardState;

  bool get hasImage => source == WebImageSource.image && image != null;

  bool get isCameraOn => source == WebImageSource.camera;

  String objectName(String label) => (labels ?? CocoLabels.english).localize(label);

  /// "Person (2), Cup" style summary, most frequent first.
  String get objectsSummary {
    final counts = <String, int>{};
    for (final o in objects.objects) {
      counts.update(objectName(o.label), (c) => c + 1, ifAbsent: () => 1);
    }
    final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => e.value > 1 ? '${e.key} (${e.value})' : e.key).join(', ');
  }
}

@freezed
class WebDashboardEvent with _$WebDashboardEvent {
  const factory WebDashboardEvent(WebDashboardEventType type) = _WebDashboardEvent;
}

enum WebDashboardEventType { textCopied }
