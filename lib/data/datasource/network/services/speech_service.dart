import 'dart:typed_data';

import 'package:dio/dio.dart';

class SpeechService {
  final Dio _dio;

  SpeechService(this._dio);

  /// Просит сервер озвучить текст и возвращает WAV.
  Future<Uint8List> synthesize({
    required String text,
    required String lang,
  }) async {
    final response = await _dio.post<List<int>>(
      "api/tts/speak",
      data: {"text": text, "lang": lang},
      options: Options(responseType: ResponseType.bytes),
    );

    return Uint8List.fromList(response.data ?? const []);
  }
}
