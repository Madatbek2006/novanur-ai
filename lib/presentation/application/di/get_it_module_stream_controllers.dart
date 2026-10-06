import 'package:nurnova_ai/domain/stream_controllers/group_refresh_stream_controller.dart';
import 'package:nurnova_ai/domain/stream_controllers/group_selection_stream_controller.dart';
import 'package:nurnova_ai/domain/stream_controllers/login_event_stream_controller.dart';
import 'package:nurnova_ai/domain/stream_controllers/profile_event_stream_controller.dart';
import 'package:nurnova_ai/domain/stream_controllers/take_photo_result_stream_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:nurnova_ai/domain/stream_controllers/app_theme_mode_stream_controller.dart';
import 'package:nurnova_ai/domain/stream_controllers/identity_refresh_stream_controller.dart';
import 'package:nurnova_ai/domain/stream_controllers/language_selection_stream_controller.dart';
import 'package:nurnova_ai/domain/stream_controllers/logout_event_stream_controller.dart';

extension GetItModuleApp on GetIt {
  Future<void> streamControllerModule() async {
    registerLazySingleton(() => AppThemeModeStreamController());
    registerLazySingleton(() => GroupChangedStreamController());
    registerLazySingleton(() => GroupSelectionStreamController());
    registerLazySingleton(() => IdentityRefreshStreamController());
    registerLazySingleton(() => LanguageSelectionStreamController());
    registerLazySingleton(() => LoginEventStreamController());
    registerLazySingleton(() => ProfileEventStreamController());
    registerLazySingleton(() => LogoutEventStreamController());
    registerLazySingleton(() => TakePhotoResultStreamController());
    await allReady();
  }
}
