part of 'scan_text_cubit.dart';

@freezed
class ScanTextState with _$ScanTextState {
  const ScanTextState._();

  @freezed
  const factory ScanTextState({
    //
    @Default(LoadingState.initial) LoadingState loadingState,
    /// Озвучка распознанного текста — тот же плеер, что под ответом в чате.
    SpeechPlayback? playback,
    @Default(<String, SpeechPlayback>{}) Map<String, SpeechPlayback> speechClips,
    //
  }) = _ScanTextState;
}

@freezed
class ScanTextEvent with _$ScanTextEvent {
  const factory ScanTextEvent(ScanTextEventType type) = _ScanTextEvent;
}

enum ScanTextEventType {
  showProgressDialog,
  hideProgressDialog,
  closePage,
}