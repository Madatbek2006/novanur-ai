part of 'chat_cubit.dart';

@freezed
class ChatState with _$ChatState {
  const ChatState._();

  const factory ChatState({
    @Default(false) bool isSendingRequest,
    XFile? takenPhotoFile,
    @Default("") String takenPhotoInBase64,
    @Default([]) List<Message> messages,
    @Default("") String uuid
}) = _ChatState;
}

@freezed
class ChatEvent with _$ChatEvent {
  const factory ChatEvent(ChatEventType type) = _ChatEvent;
}

enum ChatEventType { onShowTakenPhoto }
