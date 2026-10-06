import 'dart:ui';

enum Language {
  uzbekLatin,
  englishUs,
  russianRu;

  String getRestCode() {
    return switch (this) {
      Language.uzbekLatin => "uz",
      Language.englishUs => "en",
      Language.russianRu => "ru",
    };
  }

  String getIdentifier() {
    return switch (this) {
      Language.uzbekLatin => "uz_UZ",
      Language.englishUs => "en_EN",
      Language.russianRu => "ru_RU",
    };
  }

  Locale getLocale() {
    return switch (this) {
      Language.uzbekLatin => Locale('uz', 'UZ'),
      Language.englishUs => Locale('en', 'US'),
      Language.russianRu => Locale('ru', 'RU'),
    };
  }

  static Language valueOrDefault(String? languageName) {
    return Language.values.firstWhere(
      (e) => e.name.toUpperCase() == languageName?.toUpperCase(),
      orElse: () => defaultLanguage,
    );
  }

  static Language get defaultLanguage => Language.uzbekLatin;
}
