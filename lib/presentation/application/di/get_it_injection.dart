import 'package:get_it/get_it.dart';
import 'package:baiqavisit/presentation/application/di/get_it_module_cubit.dart';
import 'package:baiqavisit/presentation/application/di/get_it_module_database.dart';
import 'package:baiqavisit/presentation/application/di/get_it_module_network.dart';
import 'package:baiqavisit/presentation/application/di/get_it_module_preference.dart';
import 'package:baiqavisit/presentation/application/di/get_it_module_repository.dart';
import 'package:baiqavisit/presentation/application/di/get_it_module_stream_controllers.dart';

final getIt = GetIt.instance;

Future<void> initializeGetIt() async {
  await _initializeGetIt();
}

Future<void> _initializeGetIt() async {
  await GetIt.instance.preferencesModule();
  await GetIt.instance.databaseModule();
  await GetIt.instance.streamControllerModule();
  await GetIt.instance.networkModule();
  await GetIt.instance.repositoryModule();
  await GetIt.instance.appModule();

  await GetIt.instance.allReady();
}
