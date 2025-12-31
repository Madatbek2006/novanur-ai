import 'package:baiqavisit/presentation/support/state_message/state_message.dart';

abstract class StateMessageManager {
  void setListeners({
    required void Function(StateMessage message) onShowBottomSheet,
    required void Function(StateMessage message) onShowSnackBar,
  });

  void showErrorBottomSheet(String message, [String? title]);

  void showInfoBottomSheet(String message, [String? title]);

  void showSuccessBottomSheet(String message, [String? title]);

  void showWarningBottomSheet(String message, [String? title]);

  void showErrorSnackBar(String message, [String? title]);

  void showInfoSnackBar(String message, [String? title]);

  void showSuccessSnackBar(String message, [String? title]);

  void showWarningSnackBar(String message, [String? title]);
}
