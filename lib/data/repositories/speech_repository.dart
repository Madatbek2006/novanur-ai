import 'dart:typed_data';

import 'package:nurnova_ai/data/datasource/network/services/speech_service.dart';

class SpeechRepository {
  final SpeechService _speech;

  SpeechRepository(this._speech);

  Future<Uint8List> synthesize({
    required String text,
    required String lang,
  }) {
    return _speech.synthesize(text: text, lang: lang);
  }
}
