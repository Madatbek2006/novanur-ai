part of 'object_detection_cubit.dart';

@freezed
class ObjectDetectionState with _$ObjectDetectionState {
  const ObjectDetectionState._();

  const factory ObjectDetectionState({
    @Default(false) bool isSendingRequest,
    XFile? takenPhotoFile,
    @Default("") String takenPhotoInBase64,
    @Default([]) List<SMS> incomingMessages,
    @Default([]) List<SMS> outgoingMessages,
    @Default("") String uuid
}) = _ObjectDetectionState;
}

@freezed
class ObjectDetectionEvent with _$ObjectDetectionEvent {
  const factory ObjectDetectionEvent(ObjectDetectionEventType type) = _ObjectDetectionEvent;
}

enum ObjectDetectionEventType { onShowTakenPhoto }
