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
    /// Что сейчас с озвучкой: какое сообщение, на какой стадии и можно ли
    /// его перематывать. Позиции здесь нет — она идёт отдельным потоком.
    SpeechPlayback? playback,
    /// Уже озвученные сообщения: длительность и огибающая каждого. Нужны,
    /// чтобы полоса плеера оставалась на месте и у тех ответов, которые
    /// сейчас молчат, — иначе переслушать их можно только вслепую.
    @Default(<String, SpeechPlayback>{}) Map<String, SpeechPlayback> speechClips,
}) = _ChatState;
}

@freezed
class ChatEvent with _$ChatEvent {
  const factory ChatEvent(ChatEventType type) = _ChatEvent;
}

enum ChatEventType { onShowTakenPhoto }
