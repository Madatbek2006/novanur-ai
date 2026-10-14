import 'package:nurnova_ai/core/enum/enums.dart';
import 'package:nurnova_ai/domain/models/chat/speech_playback.dart';
import 'package:nurnova_ai/presentation/features/common/chat/chat_speaker.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_cubit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'scan_text_cubit.freezed.dart';
part 'scan_text_state.dart';

@injectable
class ScanTextCubit
    extends BaseCubit<ScanTextState, ScanTextEvent> {

  ScanTextCubit(this._speaker) : super(ScanTextState()) {
    _speaker.onPlayback = (playback) {
      if (isClosed) return;
      updateState((state) => state.copyWith(
            playback: playback,
            speechClips: _speaker.clips,
          ));
    };
  }

  /// Тот же голос, что у чата и у остальных разделов: движок телефона, а где
  /// голоса нет — сервер. Раньше этот раздел не говорил вовсе.
  final ChatSpeaker _speaker;

  String _languageCode = 'en';

  /// Ключ озвучки: по нему полоса под текстом узнаёт свой звук.
  String speechIdFor(String text) => ChatSpeaker.keyFor(text, _languageCode);

  /// Зачитывает распознанный текст сразу, как ответ в чате: незрячему
  /// текст на экране ничего не даёт, пока его не произнесут.
  void read(String text, String languageCode) {
    _languageCode = languageCode;
    if (text.trim().isEmpty) return;
    _speaker.speak(speechIdFor(text), text, _languageCode);
  }

  /// Проговаривает служебное сообщение без плеера — например, что текста
  /// на снимке нет. Иначе тишину не отличить от «ещё распознаю».
  void announce(String text, String languageCode) {
    _languageCode = languageCode;
    _speaker.announce(text, languageCode);
  }

  void toggleSpeech(String text) =>
      _speaker.toggle(speechIdFor(text), text, _languageCode);

  void seekSpeech(Duration position) => _speaker.seek(position);

  /// Позиция воспроизведения — отдельным потоком, мимо состояния.
  Stream<Duration> get speechPositionStream => _speaker.positionStream;

  @override
  Future<void> close() async {
    _speaker.onPlayback = null;
    await _speaker.dispose();
    return super.close();
  }
}
