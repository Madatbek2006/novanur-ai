import 'package:nurnova_ai/core/enum/describe_img_type.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/presentation/application/di/get_it_injection.dart';
import 'package:nurnova_ai/presentation/features/common/chat/chat_cubit.dart';
import 'package:nurnova_ai/presentation/features/web/dashboard/web_dashboard_cubit.dart';
import 'package:nurnova_ai/presentation/features/web/widgets/web_ui.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_builder.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/widgets/chat/chat_widget.dart';
import 'package:nurnova_ai/utils/web/browser_vision.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "Describe scene": the same AI chat as the phone app, next to the image.
class DescribePanel extends StatelessWidget {
  const DescribePanel({super.key, required this.state, required this.cubit});

  final WebDashboardState state;
  final WebDashboardCubit cubit;

  @override
  Widget build(BuildContext context) {
    final image = state.image;
    final type = state.describeType;
    if (!state.hasImage || image == null) {
      return WebHint(
        icon: Icons.auto_awesome_outlined,
        text: state.isCameraOn ? Strings.webDescribeCameraHint : Strings.webSelectImageFirst,
      );
    }
    if (type == null) {
      return _TypeChooser(onSelected: cubit.startDescribing);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(type.icon, size: 20, color: context.colors.buttonPrimary),
            const SizedBox(width: 8),
            Expanded(child: type.title.s(15).w(600).c(context.textPrimary)),
            TextButton.icon(
              onPressed: cubit.resetDescribing,
              icon: const Icon(Icons.restart_alt),
              label: Text(Strings.webNewChat),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColoredBox(
              color: context.mainBg,
              child: _EmbeddedChat(key: ValueKey(state.chatSession), image: image, type: type),
            ),
          ),
        ),
      ],
    );
  }
}

extension on DescribeImgType {
  IconData get icon => switch (this) {
        DescribeImgType.short => Icons.short_text,
        DescribeImgType.detailed => Icons.notes,
        DescribeImgType.question => Icons.question_answer_outlined,
      };

  String get hint => switch (this) {
        DescribeImgType.short => Strings.webDescribeShortHint,
        DescribeImgType.detailed => Strings.webDescribeDetailedHint,
        DescribeImgType.question => Strings.webDescribeQuestionHint,
      };
}

class _TypeChooser extends StatelessWidget {
  const _TypeChooser({required this.onSelected});

  final ValueChanged<DescribeImgType> onSelected;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.buttonPrimary;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Strings.webDescribeChoose.s(16).w(600).c(context.textPrimary),
          const SizedBox(height: 14),
          for (final type in DescribeImgType.values) ...[
            Material(
              color: context.mainBg,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelected(type),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(type.icon, color: accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            type.title.s(15).w(600).c(context.textPrimary),
                            const SizedBox(height: 2),
                            type.hint.s(13).w(400).c(context.textSecondary),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: context.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _EmbeddedChat extends StatelessWidget {
  const _EmbeddedChat({super.key, required this.image, required this.type});

  final BrowserImage image;
  final DescribeImgType type;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatCubit>(
      create: (context) => getIt<ChatCubit>()
        ..setFile(
          XFile.fromData(image.bytes, name: image.name, mimeType: 'image/jpeg'),
          Localizations.localeOf(context),
          type: type,
        ),
      child: BaseBuilder<ChatCubit, ChatState, ChatEvent>(
        onWidgetBuild: (context, chatState) => ChatWidget(
          messages: chatState.messages,
          isSendingRequest: chatState.isSendingRequest,
          userUid: 'user',
          onSend: (sms) => context.read<ChatCubit>().sendSMS(sms, Localizations.localeOf(context)),
          subRoom: () {},
          unSubRoom: () {},
          audioMessages: const [],
          onUpdateAudio: (_) {},
        ),
      ),
    );
  }
}
