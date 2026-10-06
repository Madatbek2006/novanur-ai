import 'package:nurnova_ai/core/enum/enums.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/presentation/features/web/dashboard/web_dashboard_cubit.dart';
import 'package:nurnova_ai/presentation/features/web/widgets/results/speak_button.dart';
import 'package:nurnova_ai/presentation/features/web/widgets/web_ui.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class ObjectsResultPanel extends StatelessWidget {
  const ObjectsResultPanel({super.key, required this.state, required this.cubit});

  final WebDashboardState state;
  final WebDashboardCubit cubit;

  @override
  Widget build(BuildContext context) {
    if (!state.hasImage && !state.isCameraOn) {
      return WebHint(icon: Icons.category_outlined, text: Strings.webSelectImageFirst);
    }
    return switch (state.objectsState) {
      LoadingState.initial || LoadingState.loading => WebProgress(
          text: state.isCameraOn ? Strings.webObjectsLoading : Strings.webObjectsSearching,
        ),
      LoadingState.error => WebError(text: Strings.webAnalysisError, onRetry: cubit.retry),
      LoadingState.empty => WebHint(
          icon: Icons.search_off,
          text: state.isCameraOn ? Strings.webObjectsCameraHint : Strings.webObjectsEmpty,
        ),
      LoadingState.success => _buildList(context),
    };
  }

  Widget _buildList(BuildContext context) {
    // One row per kind of object, with how many and the best confidence.
    final groups = <String, ({int count, double score})>{};
    for (final object in state.objects.objects) {
      final name = state.objectName(object.label);
      final previous = groups[name];
      groups[name] = (
        count: (previous?.count ?? 0) + 1,
        score: previous == null || object.score > previous.score ? object.score : previous.score,
      );
    }
    final rows = groups.entries.toList()
      ..sort((a, b) => b.value.count != a.value.count
          ? b.value.count.compareTo(a.value.count)
          : b.value.score.compareTo(a.value.score));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: !state.isCameraOn,
          child: "${Strings.webObjectsFound}: ${state.objects.objects.length}"
              .s(15)
              .w(600)
              .c(context.textPrimary),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final row = rows[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: context.mainBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(child: row.key.s(15).w(600).c(context.textPrimary)),
                    if (row.value.count > 1) ...[
                      "×${row.value.count}".s(14).w(600).c(context.colors.buttonPrimary),
                      const SizedBox(width: 12),
                    ],
                    "${(row.value.score * 100).round()}%".s(13).w(500).c(context.textSecondary),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: SpeakButton(
            isSpeaking: state.isSpeaking,
            onSpeak: () => cubit.speak(state.objectsSummary),
            onStop: cubit.stopSpeaking,
          ),
        ),
      ],
    );
  }
}
