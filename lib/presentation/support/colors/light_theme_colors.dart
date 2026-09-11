import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:nurnova_ai/presentation/support/colors/static_colors.dart';
import 'package:nurnova_ai/presentation/support/colors/theme_colors.dart';

@lazySingleton
class LightThemeColors extends ThemeColors {
  @override
  Color get backgroundColor => StaticColors.backgroundColor;

  @override
  Color get primary => StaticColors.colorPrimary;

  @override
  Color get onPrimary => StaticColors.white;

  @override
  Color get textPrimary => StaticColors.textColorPrimary;

  @override
  Color get textAccent => StaticColors.dodgerBlue;

  @override
  Color get textSecondary => StaticColors.textColorSecondary;

  @override
  Color get textTertiary => StaticColors.cadetBlue;

  @override
  Color get textPrimaryInverse => StaticColors.white;

  @override
  Color get borderColor => StaticColors.brightGray;

  @override
  Color get buttonPrimary => StaticColors.buttonColor;

  @override
  Color get adStatusBackground => StaticColors.bondiBlue;

  @override
  Color get adPropertyBusinessBackground => StaticColors.business;

  @override
  Color get adPropertyPersonalBackground => StaticColors.manatee;

  @override
  Color get inputBackground => Color(0xFFFBFAFF);

  @override
  Color get iconPrimary => StaticColors.iconPrimaryLight;

  @override
  Color get iconSecondary => StaticColors.iconSecondary;
}
