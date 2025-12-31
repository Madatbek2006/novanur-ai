import 'package:baiqavisit/core/gen/assets/assets.gen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class GoogleSpeechDialog extends StatefulWidget {
  /// Возвращает распознанный текст
  final Function(String text) onResult;

  const GoogleSpeechDialog({super.key, required this.onResult});

  @override
  State<GoogleSpeechDialog> createState() => _GoogleSpeechDialogState();
}

class _GoogleSpeechDialogState extends State<GoogleSpeechDialog> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isClosed = false; // флаг, чтобы onResult срабатывал 1 раз
  String _text = '';
  double _level = 0.0;
  String _localeId = 'en-US';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// Универсальный вызов результата, с проверкой, закрыт ли диалог
  void _handleResult(String result) {
    if (_isClosed) return;
    _isClosed = true;
    widget.onResult(result);
    Navigator.pop(context, true);
    // if (mounted) Navigator.of(context).pop();
  }

  /// Инициализация SpeechToText и выбор языка по EasyLocalization
  Future<void> _initSpeech() async {
    final bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') _handleResult(_text);
      },
      onError: (error) {
        Logger().e('Speech error: $error');
        _handleResult(_text);
      },
    );

    if (!available) {
      _handleResult(_text);
      return;
    }

    final locale = EasyLocalization.of(context)?.currentLocale ?? const Locale("en", "US");
    final localeTag = '${locale.languageCode}_${locale.countryCode ?? locale.languageCode}';

    setState(() {
      _localeId = localeTag;
    });

    _startListening();
  }

  /// Начинаем слушать
  void _startListening() async {
    setState(() => _isListening = true);
    await _speech.listen(
      localeId: _localeId,
      onResult: (val) {
        setState(() => _text = val.recognizedWords);
        if (val.finalResult) _handleResult(val.recognizedWords);
      },
      onSoundLevelChange: (level) {
        setState(() => _level = _level * 0.8 + level * 0.2);
      },
      listenMode: stt.ListenMode.confirmation,
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
    );
  }

  /// Остановка прослушивания пользователем
  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    _handleResult(_text.isNotEmpty ? _text : ""); // если текст есть, возвращаем его
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double waveSize = (_level * 3).clamp(0, 60);

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.black.withOpacity(0.85),
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Волна вокруг микрофона
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: 120 + waveSize,
                width: 120 + waveSize,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Assets.images.component.micCircle.svg(
                    height: 120,
                    width: 120,
                    color: Colors.blueAccent,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                _text.isEmpty ? 'Скажите что-нибудь…' : _text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),

              const SizedBox(height: 24),

              IconButton(
                onPressed: _stopListening,
                icon: const Icon(Icons.stop_circle, color: Colors.redAccent),
                iconSize: 48,
              ),

              const SizedBox(height: 8),

              Text(
                'Язык: $_localeId',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
