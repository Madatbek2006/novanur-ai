import 'package:baiqavisit/core/gen/localization/strings.dart';

import 'state_message_type.dart';

class StateMessage {
  final MessageType type;
  final String message;
  final String? title;

  StateMessage(this.type, this.message, [this.title]);

  String get titleOrDefault =>
      title ??
      switch (type) {
        MessageType.error => Strings.messageTitleError,
        MessageType.info => Strings.messageTitleInfo,
        MessageType.success => Strings.messageTitleSuccess,
        MessageType.warning => Strings.messageTitleWarning,
      };
}
