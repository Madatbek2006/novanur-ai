import 'dart:async';
import 'dart:convert';

import 'package:nurnova_ai/core/enum/enums.dart';
import 'package:nurnova_ai/core/extensions/list_extensions.dart';
import 'package:nurnova_ai/core/handler/future_handler.dart';
import 'package:nurnova_ai/data/repositories/photo_analysis_repository.dart';
import 'package:nurnova_ai/domain/models/chat/sms.dart';
import 'package:nurnova_ai/domain/models/takephoto/taken_photo.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_cubit.dart';
import 'package:nurnova_ai/presentation/widgets/chat/chat_widget.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'barcode_cubit.freezed.dart';

part 'barcode_state.dart';

@injectable
class BarcodeCubit extends BaseCubit<BarcodeState, BarcodeEvent> {
  BarcodeCubit(this._photoAnalysisRepository) : super(BarcodeState());
  WebSocketChannel? channel;
  bool _isSendingRequest = false;
  final FlutterTts flutterTts = FlutterTts();


  final PhotoAnalysisRepository _photoAnalysisRepository;







  void getProductData(String? barcode){
    if(_isSendingRequest || barcode==null) return;
    _isSendingRequest=true;
    _photoAnalysisRepository.getProductData(barcode)
        .initFuture()
        .onStart(() {})
        .onSuccess((data) {
          flutterTts.speak(data);
          Future.delayed(Duration(seconds: 5),(){
            _isSendingRequest=false;
          });
        })
        .onError((error) {
          _isSendingRequest=false;
        })
        .onFinished(() {})
        .executeFuture();
  }
}
