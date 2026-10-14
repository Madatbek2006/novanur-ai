import 'package:flutter/material.dart';
import 'package:nurnova_ai/presentation/features/web/dashboard/web_dashboard_cubit.dart';
import 'package:nurnova_ai/presentation/widgets/speech/speech_control.dart';

/// Полоса озвучки под результатом — та же, что под ответом в чате.
///
/// Раньше здесь была кнопка «Прослушать», которая звала голос браузера в
/// обход общего спикера: без перемотки, без волны и без узбекского.
class WebSpeechControl extends StatelessWidget {
  const WebSpeechControl({
    super.key,
    required this.state,
    required this.cubit,
    required this.text,
    this.languageCode,
  });

  final WebDashboardState state;
  final WebDashboardCubit cubit;

  /// Что читать. Ключ озвучки считается из этого текста и языка.
  final String text;

  /// Язык чтения. По умолчанию — язык интерфейса.
  final String? languageCode;

  @override
  Widget build(BuildContext context) {
    return SpeechControl(
      speechId: cubit.speechIdFor(text, languageCode: languageCode),
      playback: state.playback,
      clips: state.speechClips,
      positionStream: cubit.speechPositionStream,
      onToggle: () => cubit.toggleSpeech(text, languageCode: languageCode),
      onSeek: cubit.seekSpeech,
    );
  }
}
