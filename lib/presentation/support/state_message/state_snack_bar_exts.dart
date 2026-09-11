import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/presentation/support/colors/static_colors.dart';
import 'package:nurnova_ai/presentation/support/state_message/state_message.dart';
import 'package:nurnova_ai/presentation/support/state_message/state_message_type.dart';

extension StateSnackBarExts on BuildContext {
  void showStateMessageSnackBar(StateMessage message) =>
      showCustomSnackBar(message.titleOrDefault, message.message);

  void showCustomSnackBar(
    String title,
    String message, [
    MessageType type = MessageType.info,
    Color backgroundColor = StaticColors.toastDefaultBackgroundColor,
    SnackBarBehavior behavior = SnackBarBehavior.fixed,
    Duration duration = const Duration(milliseconds: 2500),
  ]) {
    // ScaffoldMessenger.of(this).showSnackBar(
    //   SnackBar(
    //     content: Center(
    //         child: Column(
    //       children: [
    //         SizedBox(height: 6),
    //         Text(message),
    //         SizedBox(height: 6),
    //       ],
    //     )),
    //     backgroundColor: backgroundColor,
    //     behavior: behavior,
    //     duration: duration,
    //     shape: RoundedRectangleBorder(
    //         // borderRadius: BorderRadius.circular(10.0),
    //         ),
    //   ),
    // );

    final IconData icon;
    final Color color;
    switch (type) {
      case MessageType.error:
        icon = Icons.error;
        color = Colors.red;
        break;
      case MessageType.warning:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case MessageType.info:
        icon = Icons.info_outline;
        color = Colors.blue;
        break;
      case MessageType.success:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
    }

    ElegantNotification(
      title: title.s(16).w(600).c(color),
      description: message.s(14).w(400).c(color),
      icon: Icon(icon, color: color),
      position: Alignment.topCenter,
      animation: AnimationType.fromTop,
      progressIndicatorColor: color,
    ).show(this);
  }
}
