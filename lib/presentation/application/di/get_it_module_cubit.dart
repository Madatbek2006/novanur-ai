import 'package:baiqavisit/presentation/features/common/barcode/barcode_cubit.dart';
import 'package:baiqavisit/presentation/features/common/chat/chat_cubit.dart';
import 'package:baiqavisit/presentation/features/common/object_detection/object_detection_cubit.dart';
import 'package:baiqavisit/presentation/features/common/scan_text/scan_text_cubit.dart';
import 'package:baiqavisit/presentation/features/common/takephoto/take_photo_cubit.dart';
import 'package:baiqavisit/presentation/features/home/features/dashboard/dashboard_cubit.dart';
import 'package:baiqavisit/presentation/features/home/features/profile/profile_cubit.dart';
import 'package:baiqavisit/presentation/features/home/home_cubit.dart';
import 'package:baiqavisit/presentation/support/state_message/state_message_manager.dart';
import 'package:baiqavisit/presentation/support/state_message/state_message_manager_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

extension GetItModuleApp on GetIt {
  Future<void> appModule() async {
    registerLazySingleton(() => Logger());

    registerSingleton<StateMessageManager>(StateMessageManagerImpl());

    // home
    registerFactory(() => HomeCubit());

    registerFactory(() => DashboardCubit());
    registerFactory(
      () => ProfileCubit(get(), get(), get(), get(), get()),
    );


    // take photo
    registerFactory(() => TakePhotoCubit());
    registerFactory(() => ChatCubit(get()));
    registerFactory(() => BarcodeCubit(get()));
    registerFactory(() => ObjectDetectionCubit(get()));
    registerFactory(() => ScanTextCubit());


    await allReady();
  }
}
