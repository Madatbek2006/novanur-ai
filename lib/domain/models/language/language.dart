import 'dart:ui';

enum Language {
  uzbekLatin,
  englishUs,
  russianRu,
  kazakhCyrill;

  String getRestCode() {
    return switch (this) {
      Language.uzbekLatin => "uz",
      Language.englishUs => "en",
      Language.russianRu => "ru",
      Language.kazakhCyrill => "kk",
    };
  }

  String getIdentifier() {
    return switch (this) {
      Language.uzbekLatin => "uz_UZ",
      Language.englishUs => "en_EN",
      Language.russianRu => "ru_RU",
      Language.kazakhCyrill => "kk_KZ",
    };
  }

  Locale getLocale() {
    return switch (this) {
      Language.uzbekLatin => Locale('uz', 'UZ'),
      Language.englishUs => Locale('en', 'US'),
      Language.russianRu => Locale('ru', 'RU'),
      Language.kazakhCyrill => Locale('kk', 'KZ'),
    };
  }

  static Language valueOrDefault(String? languageName) {
    return Language.values.firstWhere(
      (e) => e.name.toUpperCase() == languageName?.toUpperCase(),
      orElse: () => defaultLanguage,
    );
  }

  static Language get defaultLanguage => Language.kazakhCyrill;
}
