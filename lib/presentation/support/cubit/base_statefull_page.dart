import 'package:auto_route/auto_route.dart';
import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/presentation/application/di/get_it_injection.dart';
import 'package:baiqavisit/presentation/support/colors/static_colors.dart';
import 'package:baiqavisit/presentation/support/cubit/base_builder.dart';
import 'package:baiqavisit/presentation/support/cubit/base_event.dart';
import 'package:baiqavisit/presentation/support/cubit/base_state.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:baiqavisit/presentation/support/extensions/platform_sizes.dart';
import 'package:baiqavisit/presentation/support/state_message/state_bottom_sheet_exts.dart';
import 'package:baiqavisit/presentation/support/state_message/state_message_type.dart';
import 'package:baiqavisit/presentation/widgets/bottom_sheet/bottom_sheet_title.dart';
import 'package:baiqavisit/presentation/widgets/button/custom_elevated_button.dart';
import 'package:baiqavisit/presentation/widgets/button/custom_outlined_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

abstract class BaseStatefulPage<
CUBIT extends Cubit<BaseState<STATE, EVENT>>,
STATE,
EVENT> extends StatefulWidget {
  const BaseStatefulPage({Key? key}) : super(key: key);
}

abstract class BaseStatefulPageState<
PAGE extends BaseStatefulPage<CUBIT, STATE, EVENT>,
CUBIT extends Cubit<BaseState<STATE, EVENT>>,
STATE,
EVENT> extends State<PAGE> {
  late final CUBIT _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<CUBIT>();
    onWidgetCreated();
  }

  @override
  void dispose() {
    // Если кубит не используется где-то ещё — можно задиспозить
    // _cubit.close();
    super.dispose();
  }

  // === Переопределяемые методы ===

  /// Вызывается один раз после создания виджета (аналог onWidgetCreated)
  void onWidgetCreated() {}

  /// Обработка событий из кубита
  void onEventEmitted(EVENT event) {}

  /// Основной билд контента страницы
  Widget onWidgetBuild(BuildContext context, STATE state);

  // === Утилиты ===

  CUBIT cubit() => _cubit;

  STATE? get currentState => _cubit.state.state;

  // === Стандартные методы из твоего BasePage ===

  void showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      useSafeArea: false,
      builder: (_) => PopScope(
        canPop: true,
        child: Center(
          child: CircularProgressIndicator(color: StaticColors.dodgerBlue),
        ),
      ),
    );
  }

  void hideProgressBarDialog(BuildContext context) {
    context.router.maybePop();
  }

  void showErrorBottomSheet(BuildContext context, String message) =>
      context.showStateBottomSheet(
        Strings.messageTitleError,
        message,
        MessageType.error,
      );

  void showInfoBottomSheet(BuildContext context, String message) =>
      context.showStateBottomSheet(
        Strings.messageTitleInfo,
        message,
        MessageType.info,
      );

  void showSuccessBottomSheet(BuildContext context, String message) =>
      context.showStateBottomSheet(
        Strings.messageTitleSuccess,
        message,
        MessageType.success,
      );

  void showWarningBottomSheet(BuildContext context, String message) =>
      context.showStateBottomSheet(
        Strings.messageTitleWarning,
        message,
        MessageType.warning,
      );

  void showYesNoBottomSheet(
      BuildContext context, {
        required String title,
        required String message,
        required String yesTitle,
        required Function onYesClicked,
        required String noTitle,
        required Function onNoClicked,
      }) {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => Material(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 24),
            BottomSheetTitle(title: title),
            SizedBox(height: 24),
            Center(child: message.s(16).copyWith(textAlign: TextAlign.center)),
            SizedBox(height: 32),
            Row(
              children: <Widget>[
                SizedBox(width: 16),
                Expanded(
                  child: CustomOutlinedButton(
                    text: noTitle,
                    textColor: StaticColors.attendanceAccepted,
                    strokeColor: StaticColors.attendanceAccepted,
                    onPressed: () {
                      onNoClicked();
                      Navigator.pop(context);
                      HapticFeedback.heavyImpact();
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CustomOutlinedButton(
                    text: yesTitle,
                    textColor: StaticColors.attendanceAbsent,
                    strokeColor: StaticColors.attendanceAbsent,
                    onPressed: () {
                      onYesClicked();
                      Navigator.pop(context);
                      HapticFeedback.heavyImpact();
                    },
                  ),
                ),
                SizedBox(width: 16),
              ],
            ),
            SizedBox(height: defaultBottomPadding),
          ],
        ),
      ),
    );
  }

  void showDefaultDatePickerDialog(
      BuildContext context, {
        DateTime? selectedDate,
        int minimumYear = 1930,
        int maximumYear = 2024,
        required Function(String date) onDateSelected,
      }) {
    final dateFormat = DateFormat("yyyy-MM-dd");
    final initialDate = selectedDate ?? DateTime.now();
    var formattedDate = dateFormat.format(initialDate);

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext buildContext) {
        return Container(
          decoration: BoxDecoration(
            color: context.bottomSheetColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 320,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(brightness: context.brightness),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: initialDate,
                        minimumYear: minimumYear,
                        maximumYear: maximumYear,
                        onDateTimeChanged: (DateTime newDateTime) {
                          formattedDate = dateFormat.format(newDateTime);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomElevatedButton(
                      text: Strings.commonSave,
                      onPressed: () {
                        onDateSelected(formattedDate);
                        Navigator.of(buildContext).pop();
                      },
                    ),
                  ),
                  SizedBox(height: defaultBottomPadding),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showToast(
      BuildContext context,
      String message,
      bool isSuccess,
      ) {
    final color = isSuccess ? Colors.green : Colors.red;
    final icon = isSuccess ? Icons.check_circle : Icons.error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          right: 20,
          left: 20,
        ),
        elevation: 6,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CUBIT>(
      create: (_) => _cubit,
      child: BaseListener<CUBIT, STATE, EVENT>(
        onEventEmitted: onEventEmitted,
        widget: BaseBuilder<CUBIT, STATE, EVENT>(
          onWidgetBuild: (context, state) => onWidgetBuild(context, state),
        ),
      ),
    );
  }
}