import 'package:flutter/material.dart';
import 'package:nurnova_ai/presentation/support/colors/dark_theme_colors.dart';
import 'package:nurnova_ai/presentation/support/colors/light_theme_colors.dart';
import 'package:nurnova_ai/presentation/support/colors/static_colors.dart';
import 'package:nurnova_ai/presentation/support/colors/theme_colors.dart';

extension ColorExtension on BuildContext {
  ThemeColors get colors => isDarkMode ? DarkThemeColors() : LightThemeColors();

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Brightness get brightness => Theme.of(this).brightness;

  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  Color get colorPrimary => StaticColors.colorPrimary;

  Color get backgroundGreyColor =>
      isDarkMode ? Color(0xFF121212) : Color(0xFFF2F4FB);


  Color get bgColor => isDarkMode ? Colors.grey[900]! : Color(0xFFE4E3E9);

  Color get bgDrawerColor => isDarkMode ? Color(0xFF333333) : Color(0xFFFFFFFF);


  Color get primaryLight => isDarkMode ? StaticColors.colorPrimary : Color(0xFF6771D2);
  Color get secondaryLight => isDarkMode ? Color(0xFF15D2E9) : Color(0xFF15D2E9);

  Color get backgroundWhiteColor => Theme.of(this).colorScheme.secondary;

  // Color get bottomSheetColor => Theme.of(this).colorScheme.surface;
  Color get bottomSheetColor =>
      isDarkMode ? Color(0xFF121212) : Color(0xFFF2F4FB);

  Color get bottomNavigationColor => Theme.of(this).colorScheme.background;

  // Color get appBarColor => Theme.of(this).colorScheme.secondary;
  Color get appBarColor => isDarkMode ? Color(0xFF000000) : Color(0xFFFFFFFF);

  Color get tabBarActiveColor => isDarkMode ? Color(0xFF333333) : Color(0xFFFFFFFF);

  Color get bottomBarColor => isDarkMode ? Color(0xFF000000) : Color(0xFFFFFFFF);

  Color get cardColor => isDarkMode ? Color(0xFF333333) : Color(0xFFFFFFFF);

  Color get containerColorWhite => isDarkMode ? Color(0xFF424242) : Color(0xFFFFFFFF);
  Color get containerColorGrey => isDarkMode ? Color(0xFF333333) : Color(0xFFFBFBFB);
  Color get containerBorderColor => isDarkMode ? Color(0xFF333333) : Color(0xFFDDDDDD);
  Color get containerInfoBcColor => isDarkMode ? Color(0xFF333333) : Color(0xFFF8F8F8);

  Color get cardStrokeColor => Theme.of(this).cardColor;

  Color get textPrimary => colors.textPrimary;

  Color get textSecondary => colors.textSecondary;

  Color get textTertiary => colors.textTertiary;

  Color get textPrimaryInverse => colors.textPrimaryInverse;

  Color get inputBackgroundColor =>
      isDarkMode ? Color(0xFF333333) : Color(0xFFFFFFFF);

  Color get inputStrokeActiveColor => colors.buttonPrimary;

  Color get inputStrokeInactiveColor =>
      isDarkMode ? Color(0xFF424242) : Color(0xFFDFE2E9);

  Color get outlinedButtonStroke =>
      isDarkMode ? Color(0xFF4393C7) : Color(0xFF4393C7);

  Color get outlinedButtonStrokeGrey =>
      isDarkMode ? Color(0xFF424242) : Color(0xFFDFDFDF);

  Color get outlinedButtonBackground =>
      isDarkMode ? Color(0xFF333333) : Color(0x4DE1E1E1);

  Color get iconPrimary =>
      isDarkMode ? StaticColors.iconPrimaryDark : StaticColors.iconPrimaryLight;

  Color get iconSecondary => colors.iconSecondary;

  Color get bottomSelectColor => primaryLight;

  Color get bottomUnSelectColor =>
      isDarkMode ? Color(0xFFA0A0A0) : Color(0xFF6E7590);

  Color get borderStroke => isDarkMode ? Color(0xFF424242) : Color(0xFFECEFF5);
  Color get mainBg =>
      isDarkMode ? Color(0xFF000000) : Color(0xFFF4F6FB);
}
