import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:nurnova_ai/core/enum/describe_img_type.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/core/handler/future_handler.dart';
import 'package:nurnova_ai/data/datasource/network/constants/constants.dart';
import 'package:nurnova_ai/data/repositories/photo_analysis_repository.dart';
import 'package:nurnova_ai/presentation/features/common/chat/chat_speaker.dart';
import 'package:nurnova_ai/domain/models/chat/sms.dart';
import 'package:nurnova_ai/domain/models/chat/speech_playback.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_cubit.dart';
import 'package:nurnova_ai/presentation/support/extensions/extension_message_exts.dart';
import 'package:nurnova_ai/utils/extension/image.dart';
import 'package:camera/camera.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:just_audio/just_audio.dart';

part 'chat_cubit.freezed.dart';

part 'chat_state.dart';

@injectable
class ChatCubit extends BaseCubit<ChatState, ChatEvent> {
  ChatCubit(this._photoAnalysisRepository, this._speaker) : super(ChatState()){
    _setupAudio();
    _player.setVolume(0.3);
    _speaker.onPlayback = (playback) =>
        updateState((state) => state.copyWith(playback: playback));
  }
  WebSocketChannel? channel;
  final AudioPlayer _player = AudioPlayer();
  final ChatSpeaker _speaker;

  /// Язык, на котором пришёл запрос: на нём же читаем ответ вслух.
  String _languageCode = 'en';

  /// Что повторить по кнопке «Повторить» после ошибки.
  VoidCallback? _retryAction;

  /// Сокет закрыли осознанно — переподключаться не нужно.
  bool _closedByUser = false;

  /// Держится ли соединение. Без него запрос уходит в никуда: sink принимает
  /// сообщение и молча его теряет, а пользователь ждёт ответ, которого не будет.
  bool _socketConnected = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

  /// Сколько раз пробуем восстановить соединение, прежде чем сдаться.
  static const _maxReconnectAttempts = 3;



  Future<void> _setupAudio() async {
    await _player.setAsset('assets/song/progress_audio.mp3');
    _player.setLoopMode(LoopMode.one);

  }

  final PhotoAnalysisRepository _photoAnalysisRepository;

  String aiImageDescriptionPrompt = "";

  void setFile(XFile file,Locale locale,{DescribeImgType? type}) async{
    _languageCode = locale.languageCode;
    _retryAction = () => setFile(file, locale, type: type);
    updateState((state) => state.copyWith(error: null));
    var base64 = base64Encode(await file.readAsBytes());
    Logger().d("TTT=> $base64");
    updateState((state) => state.copyWith(
        takenPhotoFile: file,
        messages: [ImageMessage(author: User(id: "user"),
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: file.name,
          size: 0,
          uri: base64
      )]
    ));
    _photoAnalysisRepository
        .fetchPhotoAnalysis(states.takenPhotoFile!)
        .initFuture()
        .onStart(() {
      logger.d("TTT=> onStart");
    })
        .onSuccess((data) {
      logger.d("TTT=> onSuccess");
          updateState((state) => state.copyWith(uuid: data));
          startWebSocket();
          sendSMS(Strings.commonDescribeImage,locale,type: type);
        })
        .onError((error) {
          logger.d("TTT=> $error");
          _failWith(Strings.chatErrorNoConnection);
        })
        .onFinished(() {})
        .executeFuture();
  }

  void sendSMS(String sms,Locale locale,{DescribeImgType? type}) {
    _languageCode = locale.languageCode;
    _retryAction = () => sendSMS(sms, locale, type: type);
    updateState((state) => state.copyWith(error: null));
    Logger().d("TTT=> ${type?.name}");
    try {
      if (DescribeImgType.question.value == type?.value) return;
      updateState((state) =>
          state.copyWith(
              messages: sortMessage(state.messages,  TextMessage(
                author: User(id: "user"),
                createdAt: DateTime
                    .now()
                    .millisecondsSinceEpoch,
                id: DateTime
                    .now()
                    .millisecondsSinceEpoch
                    .toString(),
                text: sms,
              )),
              isSendingRequest: true
          ));
      _player.play();
      _send(jsonEncode({
        "action": type?.value ?? DescribeImgType.question.value,
        "timestamp": DateTime
            .now()
            .millisecondsSinceEpoch
            .toString(),
        "data": {
          "lang": locale.languageCode,
          "max_tokens": 100,
          "message": sms
        }
      }
      ));
      logger.d(
          "TTT=> ${states.takenPhotoFile == null}////${states.takenPhotoFile}");
    }catch(error){
      logger.d("TTTT=> ${error?.localizedMessage}///${error?.toString()}");
      _failWith(Strings.chatErrorNoConnection);
    }
  }

  void startWebSocket() {
    _closedByUser = false;
    _reconnectTimer?.cancel();
    try {
      channel = WebSocketChannel.connect(
        Uri.parse('${Constants.baseUrlWs}ws/connect?chat_id=${states.uuid}'),
      );
      Logger().d("TTT=> ${states.uuid}");

      logger.i("TTT=> Попытка подключения к WebSocket...   ${states.uuid}");
      try {
        channel?.stream.listen(
          (event) {
            logger.d("TTT=> Сообщение: $event");
            final data = jsonDecode(event);
            if(data["type"]=="ping"){
              Logger().d("TTT=> ping");
              _send(jsonEncode({
                "type": "pong"
              }));
            }else{
              final text = data["data"]["message"]?.toString() ?? '';
              // Один и тот же id у сообщения и у отметки «читается сейчас»:
              // по нему кнопка на пузыре знает, что именно остановить.
              final id = DateTime.now().millisecondsSinceEpoch.toString();

              updateState((state) => state.copyWith(
                    messages: sortMessage(state.messages, TextMessage(
                      author: User(id: "AI"),
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                      id: id,
                      text: text,
                    )),
                    // ответ дошёл — значит связь жива
                    error: null,
                  ));

              stopProgress();
              _reconnectAttempts = 0;
              // Состояние озвучки дальше ведёт сам спикер: он знает,
              // синтезируется звук или уже играет.
              _speaker.speak(id, text, _languageCode);
            }
          },
          onError: (error) {
            logger.e("TTT=> Ошибка WebSocket: $error");
            _scheduleReconnect();
          },
          onDone: () {
            logger.w("TTT=> WebSocket соединение закрыто");
            _scheduleReconnect();
          },
        );
      } catch (error) {
        stopProgress();
        logger.e("TTT=> Ошибка2 WebSocket: $error");
      }
      _socketConnected = true;
      stopProgress();
      logger.i("TTT=>  подключились к WebSocket");
    } catch (e) {
      stopProgress();
      logger.e("TTT=> Не удалось подключиться к WebSocket: $e");
    }
  }
  /// Одна кнопка на все состояния озвучки.
  ///
  /// Для серверного звука это пауза и продолжение — файл никуда не делся,
  /// возвращаться к началу незачем. Для движка телефона паузы не существует,
  /// поэтому повторное нажатие просто обрывает чтение.
  void toggleSpeech(String messageId, String text) {
    final playback = states.playback;

    if (playback?.messageId == messageId) {
      switch (playback!.status) {
        case SpeechStatus.playing:
          if (playback.seekable) {
            _speaker.pause();
          } else {
            stopSpeaking();
          }
          return;
        case SpeechStatus.paused:
          _speaker.resume();
          return;
        case SpeechStatus.loading:
          // Звук ещё синтезируется — нажатие отменяет ожидание.
          stopSpeaking();
          return;
      }
    }

    _speaker.speak(messageId, text, _languageCode);
  }

  /// Перемотка. Работает только там, где звук — это файл.
  void seekSpeech(Duration position) => _speaker.seek(position);

  /// Позиция воспроизведения. Отдаётся потоком, а не через состояние:
  /// иначе каждый её тик перерисовывал бы весь список сообщений.
  Stream<Duration> get speechPositionStream => _speaker.positionStream;

  /// Обрывает чтение вслух — например, когда уходят с экрана.
  void stopSpeaking() {
    _speaker.stop();
    updateState((state) => state.copyWith(playback: null));
  }

  /// Повторяет последний запрос после ошибки. Если связь до этого оборвалась
  /// совсем, сокет сначала поднимается заново — иначе повтор уйдёт в мёртвый
  /// канал и пользователь будет ждать ответ, который не придёт.
  void retry() {
    updateState((state) => state.copyWith(error: null));
    _reconnectAttempts = 0;

    if (!_socketConnected && states.uuid.isNotEmpty) {
      startWebSocket();
    }

    _retryAction?.call();
  }

  /// Показывает ошибку и проговаривает её: без озвучки незрячий пользователь
  /// не отличит сбой от «модель ещё думает».
  void _failWith(String message) {
    stopProgress();
    updateState((state) => state.copyWith(error: message));
    _speaker.announce(message, _languageCode);
  }

  /// Сокет рвётся сам по себе — на переключении сети, при уходе в фон.
  /// Пробуем поднять его заново с нарастающей паузой, а когда попытки
  /// кончились — говорим об этом вслух.
  void _scheduleReconnect() {
    _socketConnected = false;
    if (_closedByUser || isClosed || states.uuid.isEmpty) return;

    stopProgress();

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _failWith(Strings.chatErrorNoConnection);
      return;
    }

    if (_reconnectAttempts == 0) {
      updateState((state) => state.copyWith(error: Strings.chatReconnecting));
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: 1 << (_reconnectAttempts - 1));
    logger.w("TTT=> переподключение через ${delay.inSeconds}с "
        "(попытка $_reconnectAttempts из $_maxReconnectAttempts)");

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_closedByUser || isClosed) return;
      startWebSocket();
    });
  }

  @override
  Future<void> close() {
    _closedByUser = true;
    _reconnectTimer?.cancel();
    channel?.sink.close();
    _speaker.dispose();
    return super.close();
  }

  void stopProgress(){
    _player.stop();
    logger.w("TTT=> stopProgress");
    updateState((state) => state.copyWith(
      isSendingRequest: false,
    ));
  }


  List<Message> sortMessage(List<Message> messages,Message message){
    var newLs= messages.toList();
    newLs.add(message);
    newLs.sort((a, b) =>
        (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return newLs;
  }


  void _send(String message) {
    channel?.sink.add(message);
  }

}
