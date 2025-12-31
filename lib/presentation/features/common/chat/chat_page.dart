import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:baiqavisit/core/enum/describe_img_type.dart';
import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/core/gen/assets/assets.gen.dart';
import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/presentation/support/colors/static_colors.dart';
import 'package:baiqavisit/presentation/support/cubit/base_page.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:baiqavisit/presentation/support/extensions/compressing_exts.dart';
import 'package:baiqavisit/presentation/widgets/app_bar/default_app_bar.dart';
import 'package:baiqavisit/presentation/widgets/bottom_sheet/bottom_sheet_title.dart';
import 'package:baiqavisit/presentation/widgets/button/custom_elevated_button.dart';
import 'package:baiqavisit/presentation/widgets/button/custom_outlined_button.dart';
import 'package:baiqavisit/presentation/widgets/chat/chat_widget.dart';
import 'package:baiqavisit/presentation/widgets/image/rounded_cached_network_image_widget.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as lokiimage;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';

import 'chat_cubit.dart';

@RoutePage()
class ChatPage
    extends BasePage<ChatCubit, ChatState, ChatEvent> {
  final XFile photoFile;
  final DescribeImgType type;
  ChatPage(this.photoFile,this.type, {super.key});

  @override
  void onWidgetCreatedFirst(BuildContext context) {
    final local = Localizations.localeOf(context);
    cubit(context).setFile(photoFile,local,type: type);
  }


  @override
  Widget onWidgetBuild(BuildContext context, ChatState state) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop,result){
        cubit(context).onBackPress();
      },
      child: Scaffold(
        appBar: DefaultAppBar(titleText: 'Chat',onBackPressed: (){
          context.router.popForced();
        }, ),
        body: Container(
          child: _buildBody(context, state),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ChatState state) {
    final local = Localizations.localeOf(context);
    // return Container();
    return ChatWidget(
      messages: state.messages,
      onSend: (sms) {
        cubit(context).sendSMS(sms,local);
      }, userUid: 'user',
      unSubRoom: () {

      },
      isSendingRequest: state.isSendingRequest,
      subRoom: () {  }, audioMessages: [],
      onUpdateAudio: (AudioMessage ) {  },
      // isSendingRequest: state.isSendingRequest,
      // image: photoFile,
    );
  }

}
