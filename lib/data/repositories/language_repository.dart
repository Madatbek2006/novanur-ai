import 'package:baiqavisit/data/datasource/floor/dao/group_entity_dao.dart';
import 'package:baiqavisit/data/datasource/preference/language_preferences.dart';
import 'package:baiqavisit/domain/models/language/language.dart';

class LanguageRepository {
  final GroupEntityDao _categoryEntityDao;
  final LanguagePreferences _languagePreferences;

  LanguageRepository(
    this._categoryEntityDao,
    this._languagePreferences,
  );

  Language getLanguage() {
    return _languagePreferences.language;
  }

  bool isLanguageSelected() {
    return _languagePreferences.isLanguageSelected;
  }

  Future<void> setLanguage(Language language) async {
    await _categoryEntityDao.clear();

    return _languagePreferences.setLanguage(language);
  }
}
