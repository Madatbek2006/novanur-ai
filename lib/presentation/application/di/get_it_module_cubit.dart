import 'package:nurnova_ai/presentation/features/common/barcode/barcode_cubit.dart';
import 'package:nurnova_ai/presentation/features/common/chat/chat_cubit.dart';
import 'package:nurnova_ai/presentation/features/common/chat/chat_speaker.dart';
import 'package:nurnova_ai/presentation/features/common/object_detection/object_detection_cubit.dart';
import 'package:nurnova_ai/presentation/features/common/scan_text/scan_text_cubit.dart';
import 'package:nurnova_ai/presentation/features/common/takephoto/take_photo_cubit.dart';
import 'package:nurnova_ai/presentation/features/home/features/dashboard/dashboard_cubit.dart';
import 'package:nurnova_ai/presentation/features/home/features/profile/profile_cubit.dart';
import 'package:nurnova_ai/presentation/features/home/home_cubit.dart';
import 'package:nurnova_ai/presentation/support/state_message/state_message_manager.dart';
import 'package:nurnova_ai/presentation/support/state_message/state_message_manager_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

extension GetItModuleApp on GetIt {
  Future<void> appModule() async {
    registerLazySingleton(() => Logger());

    registerSingleton<StateMessageManager>(StateMessageManagerImpl());

    // home
    registerFactory(() => HomeCubit());

    registerFactory(() => DashboardCubit(get()));
    registerFactory(
      () => ProfileCubit(get(), get(), get(), get(), get()),
    );


    // take photo
    registerFactory(() => TakePhotoCubit());
    registerFactory(() => ChatSpeaker(get()));
    registerFactory(() => ChatCubit(get(), get()));
    registerFactory(() => BarcodeCubit(get()));
    registerFactory(() => ObjectDetectionCubit(get()));
    registerFactory(() => ScanTextCubit());


    await allReady();
  }
}
