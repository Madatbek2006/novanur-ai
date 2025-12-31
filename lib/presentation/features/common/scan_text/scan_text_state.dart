part of 'scan_text_cubit.dart';

@freezed
class ScanTextState with _$ScanTextState {
  const ScanTextState._();

  @freezed
  const factory ScanTextState({
    //
    @Default(LoadingState.initial) LoadingState loadingState,
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