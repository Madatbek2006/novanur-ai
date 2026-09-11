import 'dart:async';
import 'dart:io';


import 'package:nurnova_ai/domain/models/language/language.dart';
import 'package:nurnova_ai/firebase_options.dart';
import 'package:nurnova_ai/presentation/application/di/get_it_injection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:store_checker/store_checker.dart';
import 'package:uuid/uuid.dart';

import 'data/datasource/device/device_info_holder.dart';
import 'presentation/application/application.dart';
import 'presentation/application/service/fcm_messaging_service.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });

    // await initializeFirebase();
    // await FirebaseMessagingService.init();

    await initializeGetIt();

    await EasyLocalization.ensureInitialized();

    await _prepareDeviceInfoHolder();

    runApp(
      EasyLocalization(
        supportedLocales: Language.values.map((e) => e.getLocale()).toList(),
        path: 'assets/localization',
        fallbackLocale: Language.defaultLanguage.getLocale(),
        child: Application(),
      ),
    );
  }, (error, stackTrace) {
    Logger().e("application launch error = $error $stackTrace");
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

// Future<void> initializeFirebase() async {
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//
//     FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
//
//     final remoteConfig = FirebaseRemoteConfig.instance;
//     await remoteConfig.setConfigSettings(RemoteConfigSettings(
//       fetchTimeout: const Duration(seconds: 10),
//       minimumFetchInterval: const Duration(minutes: 30),
//     ));
//     // await remoteConfig.setDefaults(const {
//     //   "some_key": "Default Value",
//     // });
//     await remoteConfig.fetchAndActivate();
//   } catch (e) {
//     print(e.toString());
//   }
// }

Future<void> _prepareDeviceInfoHolder() async {
  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    String mobileOS = "Unknown";
    String appSource = "Unknown";
    String deviceName = "Unknown";

    try {
      Source installationSource = await StoreChecker.getSource;
      switch (installationSource) {
        case Source.IS_INSTALLED_FROM_PLAY_STORE:
          appSource = "PlayMarket";
          break;
        case Source.IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER:
          appSource = "PlayPackageInstaller";
          break;
        case Source.IS_INSTALLED_FROM_RU_STORE:
          appSource = "RuStore";
          break;
        case Source.IS_INSTALLED_FROM_LOCAL_SOURCE:
          appSource = "LocalSource";
          break;
        case Source.IS_INSTALLED_FROM_AMAZON_APP_STORE:
          appSource = "AmazonAppStore";
          break;
        case Source.IS_INSTALLED_FROM_HUAWEI_APP_GALLERY:
          appSource = "AppGallery";
          break;
        case Source.IS_INSTALLED_FROM_SAMSUNG_GALAXY_STORE:
          appSource = "GalaxyStore";
          break;
        case Source.IS_INSTALLED_FROM_SAMSUNG_SMART_SWITCH_MOBILE:
          appSource = "SamsungSmartSwitch";
          break;
        case Source.IS_INSTALLED_FROM_OPPO_APP_MARKET:
          appSource = "OppoAppMarket";
          break;
        case Source.IS_INSTALLED_FROM_XIAOMI_GET_APPS:
          appSource = "XiaomiGetApps";
          break;
        case Source.IS_INSTALLED_FROM_VIVO_APP_STORE:
          appSource = "VivoAppStore";
          break;
        case Source.IS_INSTALLED_FROM_OTHER_SOURCE:
          appSource = "OtherSource";
          break;
        case Source.IS_INSTALLED_FROM_APP_STORE:
          appSource = "AppStore";
          break;
        case Source.IS_INSTALLED_FROM_TEST_FLIGHT:
          appSource = "TestFlight";
          break;
        case Source.UNKNOWN:
        default:
          appSource = "Unknown";
          break;
      }
    } catch (e) {
      appSource = "Unknown";
    }

    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await deviceInfo.androidInfo;
      deviceName = "${info.manufacturer} ${info.model}";
      mobileOS = "Android ${info.version.release}";
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await deviceInfo.iosInfo;
      deviceName = info.name;
      mobileOS = "iOS ${info.systemVersion}";
    }

    var uuid = Uuid();
    DeviceInfoHolder.deviceId = uuid.v4();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    DeviceInfoHolder.deviceName = deviceName;

    DeviceInfoHolder.appVersionName = packageInfo.version;
    DeviceInfoHolder.appVersionCode = packageInfo.buildNumber;

    DeviceInfoHolder.appSource = appSource;

    DeviceInfoHolder.mobileOs = mobileOS;
  } catch (e) {
    print(e.toString());
  }
}
