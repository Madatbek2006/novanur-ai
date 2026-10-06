import 'dart:ui';

import 'package:nurnova_ai/presentation/widgets/bottom_sheet/bottom_sheet_title.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/presentation/application/di/get_it_injection.dart';
import 'package:nurnova_ai/presentation/support/colors/static_colors.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_builder.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_event.dart';
import 'package:nurnova_ai/presentation/support/cubit/base_state.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/support/extensions/platform_sizes.dart';
import 'package:nurnova_ai/presentation/support/theme/app_glass.dart';
import 'package:nurnova_ai/presentation/support/state_message/state_bottom_sheet_exts.dart';
import 'package:nurnova_ai/presentation/support/state_message/state_message_type.dart';
import 'package:nurnova_ai/presentation/widgets/button/custom_elevated_button.dart';

abstract class BasePage<CUBIT extends Cubit<BaseState<STATE, EVENT>>, STATE,
    EVENT> extends StatelessWidget {
  BasePage({Key? key}) : super(key: key);
  bool isInitial=false;

  void onWidgetCreatedFirst(BuildContext context) {}
  void onWidgetCreated(BuildContext context) {}

  void onEventEmitted(BuildContext context, EVENT event) {}

  Widget onWidgetBuild(BuildContext context, STATE state);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CUBIT>(
      create: (_) => getIt<CUBIT>(),
      child: Builder(
        builder: (context) {
          if(!isInitial){
            isInitial=true;
            onWidgetCreatedFirst(context);
          }
          onWidgetCreated(context);

          return BaseListener<CUBIT, STATE, EVENT>(
            onEventEmitted: (event) => onEventEmitted(context, event),
            widget:
                BaseBuilder<CUBIT, STATE, EVENT>(onWidgetBuild: onWidgetBuild),
          );
        },
      ),
    );
  }

  CUBIT cubit(BuildContext context) {
    return context.read<CUBIT>();
  }

  EVENT event(BuildContext context) {
    return context.read<EVENT>();
  }

  void showExitAlertDialog(BuildContext context) {
    TextButton negativeButton = TextButton(
      child: Text(Strings.commonNo),
      onPressed: () {
        context.router.pop(context);
      },
    );

    TextButton positiveButton = TextButton(
      child: Text(Strings.commonYes),
      onPressed: () {
        context.router.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Alert Title"),
      content: Text("This is the alert message."),
      actions: [negativeButton, positiveButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      useSafeArea: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: true,
          child: Center(
            child: CircularProgressIndicator(color: StaticColors.dodgerBlue),
          ),
        );
      },
    );
  }

  void hideProgressBarDialog(BuildContext context) {
    // Navigator.of(context, rootNavigator: true).pop();
    context.router.pop();
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
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassSheet(
        showGrabber: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            BottomSheetTitle(title: title),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: message.s(15).copyWith(
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _GlassActionButton(
                      label: noTitle,
                      isPrimary: false,
                      onTap: () {
                        onNoClicked();
                        Navigator.pop(ctx);
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GlassActionButton(
                      label: yesTitle,
                      isPrimary: true,
                      onTap: () {
                        onYesClicked();
                        Navigator.pop(ctx);
                        HapticFeedback.heavyImpact();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
}

class _GlassActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _GlassActionButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isPrimary
              ? LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.7)],
                )
              : LinearGradient(
                  colors: dark
                      ? [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.06),
                        ]
                      : [
                          Colors.white.withOpacity(0.65),
                          Colors.white.withOpacity(0.35),
                        ],
                ),
          border: Border.all(
            color: isPrimary
                ? primaryColor.withOpacity(0.5)
                : dark
                    ? Colors.white.withOpacity(0.20)
                    : Colors.white.withOpacity(0.7),
            width: 1,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isPrimary
                  ? Colors.white
                  : dark
                      ? Colors.white.withOpacity(0.85)
                      : Colors.black.withOpacity(0.75),
            ),
          ),
        ),
      ),
    );
  }
}
