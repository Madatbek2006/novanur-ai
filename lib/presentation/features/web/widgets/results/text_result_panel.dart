import 'package:baiqavisit/core/enum/enums.dart';
import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/presentation/features/web/dashboard/web_dashboard_cubit.dart';
import 'package:baiqavisit/presentation/features/web/widgets/results/speak_button.dart';
import 'package:baiqavisit/presentation/features/web/widgets/web_ui.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextResultPanel extends StatelessWidget {
  const TextResultPanel({super.key, required this.state, required this.cubit});

  final WebDashboardState state;
  final WebDashboardCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Strings.webOcrLanguage.s(14).w(500).c(context.textSecondary)),
            DropdownButton<OcrLanguage>(
              value: state.ocrLanguage,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(10),
              items: [
                for (final language in OcrLanguage.values)
                  DropdownMenuItem(value: language, child: Text(language.title)),
              ],
              onChanged: (language) {
                if (language != null) cubit.setOcrLanguage(language);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(child: _buildBody(context)),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (!state.hasImage) {
      return WebHint(
        icon: Icons.text_snippet_outlined,
        text: state.isCameraOn ? Strings.webTextCameraHint : Strings.webSelectImageFirst,
      );
    }
    return switch (state.textState) {
      LoadingState.initial || LoadingState.loading => _buildProgress(),
      LoadingState.empty => WebHint(icon: Icons.search_off, text: Strings.webOcrEmpty),
      LoadingState.error => WebError(text: Strings.webAnalysisError, onRetry: cubit.recognizeText),
      LoadingState.success => _buildText(context),
    };
  }

  Widget _buildProgress() {
    final recognizing = state.ocrStatus.startsWith('recognizing');
    if (!recognizing) return WebProgress(text: Strings.webOcrLoadingModel);
    return WebProgress(
      text: "${Strings.webOcrRecognizing} ${(state.ocrProgress * 100).round()}%",
      progress: state.ocrProgress,
    );
  }

  Widget _buildText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: context.mainBg,
              borderRadius: BorderRadius.circular(12),
            ),
            // SelectionArea keeps the text visible to screen readers on the web,
            // which SelectableText's text-field semantics do not.
            child: SelectionArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.recognizedText,
                  style: TextStyle(fontSize: 16, height: 1.5, color: context.textPrimary),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SpeakButton(
              isSpeaking: state.isSpeaking,
              onSpeak: cubit.speakRecognizedText,
              onStop: cubit.stopSpeaking,
            ),
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: state.recognizedText));
                cubit.textCopied();
              },
              icon: const Icon(Icons.copy_rounded),
              label: Text(Strings.webCopy),
            ),
          ],
        ),
      ],
    );
  }
}
