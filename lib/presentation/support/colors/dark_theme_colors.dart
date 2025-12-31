import 'dart:ui';

import 'package:injectable/injectable.dart';
import 'package:baiqavisit/presentation/support/colors/static_colors.dart';
import 'package:baiqavisit/presentation/support/colors/theme_colors.dart';

@lazySingleton
class DarkThemeColors extends ThemeColors {
  @override
  Color get backgroundColor => Color(0xFF1E1E1E);

  @override
  Color get primary => StaticColors.colorPrimary;

  @override
  Color get onPrimary => StaticColors.white;

  @override
  Color get textPrimary => StaticColors.white;

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
  Color get inputBackground => Color(0x80F6F7FC); //Color(0xFF333333);

  @override
  Color get iconPrimary => StaticColors.iconPrimaryDark;

  @override
  Color get iconSecondary => StaticColors.iconSecondary;
}
