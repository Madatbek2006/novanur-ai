import 'package:baiqavisit/core/gen/assets/assets.gen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class GoogleSpeechDialog extends StatefulWidget {
  final Function(String text) onResult;

  const GoogleSpeechDialog({
    super.key,
    required this.onResult,
  });

  @override
  State<GoogleSpeechDialog> createState() => _GoogleSpeechDialogState();
}

class _GoogleSpeechDialogState extends State<GoogleSpeechDialog> {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  bool _isFinished = false;

  String _text = '';
  double _level = 0.0;
  String _localeId = 'en_US';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final bool available = await _speech.initialize(
      onStatus: (status) {
        Logger().e('VVV=>  onStatus: $status');
        if (!mounted) return;

        if (status == 'notListening' && !_isFinished) {
          _finishRecognition();
        }
      },
      onError: (error) {
        Logger().e('VVV=> onError: $error');
        widget.onResult("");
        // if (!mounted) return;
        //
        // Logger().e('Speech error: $error');

        // _stopListening();

        // if (!_isFinished) {
        //   _finishRecognition();
        // }
      },
    );

    if (!available) {
      _finishRecognition();
      return;
    }

    final locale =
        EasyLocalization.of(context)?.currentLocale ??
            const Locale("en", "US");

    final localeTag =
        '${locale.languageCode}_${locale.countryCode ?? locale.languageCode}';

    if (!mounted) return;

    setState(() {
      _localeId = localeTag;
    });

    _startListening();
  }

  Future<void> _startListening() async {
    if (!mounted) return;

    setState(() => _isListening = true);

    await _speech.listen(
      localeId: _localeId,
      listenMode: stt.ListenMode.confirmation,
      pauseFor: const Duration(seconds: 4),
      listenFor: const Duration(seconds: 30),
      partialResults: true,
      cancelOnError: false,
      onResult: (result) {
        if (!mounted) return;

        setState(() {
          _text = result.recognizedWords;
        });

        if (result.finalResult && !_isFinished) {
          _finishRecognition();
        }
      },
      onSoundLevelChange: (level) {
        if (!mounted) return;

        setState(() {
          _level = _level * 0.8 + level * 0.2;
        });
      },
    );
  }

  void _finishRecognition() {
    if (_isFinished) return;
    _isFinished = true;

    _speech.stop();
    _speech.cancel();

    widget.onResult(_text);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _stopListening() {
    if (_isFinished) return;
    _finishRecognition();
  }

  @override
  void dispose() {
    _speech.stop();
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double waveSize = (_level * 3).clamp(0, 60);

    return PopScope(
      canPop: true,
      child: Dialog(
        backgroundColor: Colors.black.withOpacity(0.85),
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 32,
            horizontal: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24),
              IconButton(
                onPressed: _stopListening,
                icon: const Icon(
                  Icons.stop_circle,
                  color: Colors.redAccent,
                ),
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