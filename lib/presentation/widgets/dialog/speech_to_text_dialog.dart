import 'package:nurnova_ai/core/gen/assets/assets.gen.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:nurnova_ai/presentation/support/theme/app_glass.dart';

class GoogleSpeechDialog extends StatefulWidget {
  final Function(String text) onResult;

  const GoogleSpeechDialog({
    super.key,
    required this.onResult,
  });

  @override
  State<GoogleSpeechDialog> createState() => _GoogleSpeechDialogState();
}

class _GoogleSpeechDialogState extends State<GoogleSpeechDialog>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isFinished = false;
  String _text = '';
  double _level = 0.0;
  String _localeId = 'en_US';

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      final bool available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'notListening' && !_isFinished) {
            _finishRecognition();
          }
        },
        onError: (error) {
          if (!mounted) return;
          Logger().e('Speech error: $error');
          widget.onResult("");
          if (!_isFinished) {
            _finishRecognition();
          }
        },
      );

      if (!available) {
        _finishRecognition();
        return;
      }

      final locale = EasyLocalization.of(context)?.currentLocale ??
          const Locale("en", "US");
      final localeTag =
          '${locale.languageCode}_${locale.countryCode ?? locale.languageCode}';

      if (!mounted) return;

      setState(() {
        _localeId = localeTag;
      });

      _startListening();
    } catch (e) {
      Logger().e('Speech init error: $e');
      _finishRecognition();
    }
  }

  Future<void> _startListening() async {
    if (!mounted) return;

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
          _level = _level * 0.7 + level * 0.3;
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

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassSurface(
          blur: AppGlass.blurPanel,
          borderRadius: AppGlass.panelAll,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildVisualizer(),
              const SizedBox(height: 28),
              _buildTextSection(),
              const SizedBox(height: 32),
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualizer() {
    return SizedBox(
      height: 160,
      width: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse
          _buildPulseRing(0.4, 1.2),
          // Inner pulse
          _buildPulseRing(0.7, 1.0),
          // Main Circle
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  context.primaryLight,
                  context.primaryLight.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: context.primaryLight.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Assets.images.component.micCircle.svg(
                height: 44,
                width: 44,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseRing(double opacityBase, double scaleBase) {
    final double levelScale = 1.0 + (_level.clamp(0, 10) / 10);
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final double pulse = _pulseController.value;
        return Container(
          height: 100 * scaleBase * levelScale * (1 + pulse * 0.2),
          width: 100 * scaleBase * levelScale * (1 + pulse * 0.2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: context.primaryLight
                  .withOpacity(opacityBase * (1 - pulse)),
              width: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextSection() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          _text.isEmpty ? 'Скажите что-нибудь…' : _text,
          key: ValueKey(_text.isEmpty),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        GestureDetector(
          onTap: _finishRecognition,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent.withOpacity(0.2),
              border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
            ),
            child: const Icon(
              Icons.stop_rounded,
              color: Colors.redAccent,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Язык: ${_localeId.toUpperCase()}',
          style: TextStyle(
            color: context.textPrimary.withOpacity(0.45),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
