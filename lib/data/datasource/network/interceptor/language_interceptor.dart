import 'package:nurnova_ai/data/datasource/preference/language_preferences.dart';
import 'package:dio/dio.dart';

class LanguageInterceptor extends QueuedInterceptor {
  LanguageInterceptor(this._languagePreferences);

  final LanguagePreferences _languagePreferences;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    var restCode = _languagePreferences.language.getRestCode();

    final headers = {'Accept-Language': restCode};
    options.headers.addAll(headers);
    handler.next(options);
  }
}
