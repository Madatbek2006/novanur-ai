part of 'take_photo_cubit.dart';

@freezed
class TakePhotoState with _$TakePhotoState {
  const factory TakePhotoState({
    XFile? takenPhotoFile,
    @Default("") String takenPhotoInBase64,
  }) = _TakePhotoState;
}

@freezed
class TakePhotoEvent with _$TakePhotoEvent {
  const factory TakePhotoEvent(TakePhotoEventType type) = _TakePhotoEvent;
}

enum TakePhotoEventType { onShowTakenPhoto, openResultScreen }
