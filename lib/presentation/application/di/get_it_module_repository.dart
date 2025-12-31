import 'package:baiqavisit/data/repositories/language_repository.dart';
import 'package:baiqavisit/data/repositories/logout_repository.dart';
import 'package:baiqavisit/data/repositories/photo_analysis_repository.dart';
import 'package:baiqavisit/data/repositories/pin_code_repository.dart';
import 'package:baiqavisit/data/repositories/theme_mode_repository.dart';
import 'package:get_it/get_it.dart';

extension GetItModuleExtension on GetIt {
  Future<void> repositoryModule() async {
    registerLazySingleton(() => LanguageRepository(get(), get()));
    registerLazySingleton(() => PinCodeRepository(get()));
    registerLazySingleton(
      () => LogoutRepository(get(), get(), get(), get(), get(), get(), get()),
    );
    registerLazySingleton(() => ThemeModeRepository(get()));
    registerLazySingleton(() => PhotoAnalysisRepository(get()));

    await allReady();
  }
}
