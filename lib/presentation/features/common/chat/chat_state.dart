part of 'chat_cubit.dart';

@freezed
class ChatState with _$ChatState {
  const ChatState._();

  const factory ChatState({
    @Default(false) bool isSendingRequest,
    XFile? takenPhotoFile,
    @Default("") String takenPhotoInBase64,
    @Default([]) List<Message> messages,
    @Default("") String uuid,
    /// Текст последней ошибки: показывается в чате и проговаривается вслух.
    String? error,
    /// id сообщения, которое читается прямо сейчас, — по нему кнопка
    /// на пузыре превращается из «повторить» в «остановить».
    String? speakingMessageId,
}) = _ChatState;
}

@freezed
class ChatEvent with _$ChatEvent {
  const factory ChatEvent(ChatEventType type) = _ChatEvent;
}

enum ChatEventType { onShowTakenPhoto }
