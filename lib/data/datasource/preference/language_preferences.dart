import 'package:baiqavisit/data/datasource/preference/preferences_extensions.dart';
import 'package:baiqavisit/domain/models/language/language.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreferences {
  final SharedPreferences _preferences;

  LanguagePreferences(this._preferences);

  static const String _keyLanguage = "string_language";

  @factoryMethod
  static Future<LanguagePreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LanguagePreferences(prefs);
  }

  bool get isLanguageSelected => _preferences.containsKey(_keyLanguage);

  bool get isLanguageNotSelected => !isLanguageSelected;

  String get languageName =>
      _preferences.getString(_keyLanguage) ?? Language.defaultLanguage.name;

  Language get language => Language.valueOrDefault(languageName);

  Future<void> setLanguage(Language language) async =>
      await _preferences.setOrRemove(_keyLanguage, language.name);

  Future<void> clear() async => await _preferences.remove(_keyLanguage);
}
