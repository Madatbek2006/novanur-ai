import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:flutter/material.dart';

/// "Read aloud" that turns into "Stop" while speaking.
class SpeakButton extends StatelessWidget {
  const SpeakButton({
    super.key,
    required this.isSpeaking,
    required this.onSpeak,
    required this.onStop,
  });

  final bool isSpeaking;
  final VoidCallback onSpeak;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isSpeaking ? onStop : onSpeak,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.colors.buttonPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded),
      label: Text(isSpeaking ? Strings.webStopSpeaking : Strings.webSpeak),
    );
  }
}
