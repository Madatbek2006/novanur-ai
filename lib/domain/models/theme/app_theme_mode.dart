import 'package:flutter/material.dart';

enum AppThemeMode {
  followSystem,
  lightMode,
  darkMode;

  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.followSystem:
        return ThemeMode.system;
      case AppThemeMode.lightMode:
        return ThemeMode.light;
      case AppThemeMode.darkMode:
        return ThemeMode.dark;
    }
  }

  static AppThemeMode valueOrDefault(String? languageName) {
    return AppThemeMode.values.firstWhere(
      (e) => e.name.toUpperCase() == languageName?.toUpperCase(),
      orElse: () => AppThemeMode.followSystem,
    );
  }

  static AppThemeMode valueFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return AppThemeMode.followSystem;
      case ThemeMode.light:
        return AppThemeMode.lightMode;
      case ThemeMode.dark:
        return AppThemeMode.darkMode;
    }
  }
}
