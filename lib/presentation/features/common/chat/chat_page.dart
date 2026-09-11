import 'package:auto_route/auto_route.dart';
import 'package:nurnova_ai/core/enum/describe_img_type.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_page.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/widgets/app_bar/default_app_bar.dart';
import 'package:nurnova_ai/presentation/widgets/chat/chat_widget.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'chat_cubit.dart';

@RoutePage()
class ChatPage
    extends BasePage<ChatCubit, ChatState, ChatEvent> {
  final XFile photoFile;
  final DescribeImgType type;
  ChatPage(this.photoFile, this.type, {super.key});

  @override
  void onWidgetCreatedFirst(BuildContext context) {
    final local = Localizations.localeOf(context);
    cubit(context).setFile(photoFile, local, type: type);
  }

  @override
  Widget onWidgetBuild(BuildContext context, ChatState state) {
    final bool dark = context.isDarkMode;
    return PopScope(
      onPopInvokedWithResult: (bool didPop, result) {
        cubit(context).stopProgress();
        cubit(context).stopSpeaking();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: DefaultAppBar(
          titleText: 'Chat',
          onBackPressed: () {
            context.router.popForced();
          },
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [
                      const Color(0xFF0D1117),
                      const Color(0xFF161B27),
                      const Color(0xFF0A0E1A),
                    ]
                  : [
                      const Color(0xFFEEF2FF),
                      const Color(0xFFE1EAFF),
                      const Color(0xFFF0F4FF),
                    ],
            ),
          ),
          child: _buildBody(context, state),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ChatState state) {
    final local = Localizations.localeOf(context);
    return ChatWidget(
      topInset: MediaQuery.paddingOf(context).top + 64,
      messages: state.messages,
      onSend: (sms) {
        cubit(context).sendSMS(sms, local);
      },
      userUid: 'user',
      unSubRoom: () {},
      isSendingRequest: state.isSendingRequest,
      subRoom: () {},
      audioMessages: [],
      onUpdateAudio: (AudioMessage) {},
    );
  }
}
