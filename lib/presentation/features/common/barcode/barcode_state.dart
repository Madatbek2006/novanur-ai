part of 'barcode_cubit.dart';

@freezed
class BarcodeState with _$BarcodeState {
  const BarcodeState._();

  const factory BarcodeState({
    @Default(false) bool isSendingRequest,
    XFile? takenPhotoFile,
    @Default("") String takenPhotoInBase64,
    @Default([]) List<SMS> incomingMessages,
    @Default([]) List<SMS> outgoingMessages,
    @Default("") String uuid
}) = _BarcodeState;
}

@freezed
class BarcodeEvent with _$BarcodeEvent {
  const factory BarcodeEvent(BarcodeEventType type) = _BarcodeEvent;
}

enum BarcodeEventType { onShowTakenPhoto }
