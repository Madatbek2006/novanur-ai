import 'dart:convert';
import 'dart:ui';

import 'package:baiqavisit/core/enum/describe_img_type.dart';
import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/core/handler/future_handler.dart';
import 'package:baiqavisit/data/datasource/network/constants/constants.dart';
import 'package:baiqavisit/data/repositories/photo_analysis_repository.dart';
import 'package:baiqavisit/domain/models/chat/sms.dart';
import 'package:baiqavisit/presentation/support/cubit/base_cubit.dart';
import 'package:baiqavisit/presentation/support/extensions/extension_message_exts.dart';
import 'package:baiqavisit/utils/extension/image.dart';
import 'package:camera/camera.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

part 'chat_cubit.freezed.dart';

part 'chat_state.dart';

@injectable
class ChatCubit extends BaseCubit<ChatState, ChatEvent> {
  ChatCubit(this._photoAnalysisRepository) : super(ChatState()){
    _setupAudio();
    _player.setVolume(0.3);
  }
  WebSocketChannel? channel;
  final AudioPlayer _player = AudioPlayer();

  onBackPress(){
    stopProgress();
  }





  Future<void> _setupAudio() async {
    // Загрузка аудио из assets или сети
    await _player.setAsset('assets/song/progress_audio.mp3');

    // Включение бесконечного повторения
    _player.setLoopMode(LoopMode.one);

  }

  final PhotoAnalysisRepository _photoAnalysisRepository;

  String aiImageDescriptionPrompt = "";

  void setFile(XFile file,Locale locale,{DescribeImgType? type}) async{
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
          stopProgress();
          logger.d("TTT=> $error");

        })
        .onFinished(() {})
        .executeFuture();
  }

  void sendSMS(String sms,Locale locale,{DescribeImgType? type}) {
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
          "max_new_tokens": 100,
          "message": sms
        }
      }
      ));
      logger.d(
          "TTT=> ${states.takenPhotoFile == null}////${states.takenPhotoFile}");
    }catch(error){
      logger.d("TTTT=> ${error?.localizedMessage}///${error?.toString()}");
    }
  }

  void startWebSocket() {
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
            final message = data["data"]["message"];
            updateState((state) => state.copyWith(
                  messages: sortMessage(state.messages, TextMessage(
                    author: User(id: "AI"),
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    text: message,
                  )),
                  // outgoingMessages: [
                  //   ...state.outgoingMessages,
                  //   SMS(message, DateTime.now(), 0, 0)
                  // ],
                ));

              stopProgress();
            }
          },
          onError: (error) {


            logger.e("TTT=> Ошибка WebSocket: $error");
          },
          onDone: () {
            stopProgress();
            logger.w("TTT=> WebSocket соединение закрыто");
          },
        );
      } catch (error) {
        stopProgress();
        logger.e("TTT=> Ошибка2 WebSocket: $error");
      }
      stopProgress();
      logger.i("TTT=>  подключились к WebSocket");
    } catch (e) {
      stopProgress();
      logger.e("TTT=> Не удалось подключиться к WebSocket: $e");
    }
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
