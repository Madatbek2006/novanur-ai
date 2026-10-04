import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:baiqavisit/core/extensions/text_extensions.dart';
import 'package:baiqavisit/core/gen/localization/strings.dart';
import 'package:baiqavisit/core/handler/future_handler.dart';
import 'package:baiqavisit/data/datasource/preference/auth_preferences.dart';
import 'package:baiqavisit/data/datasource/preference/fcm_token_preferences.dart';
import 'package:baiqavisit/data/datasource/preference/language_preferences.dart';
import 'package:baiqavisit/data/datasource/preference/pin_code_preferences.dart';
import 'package:baiqavisit/data/datasource/preference/theme_mode_preferences.dart';
import 'package:baiqavisit/data/datasource/preference/token_holder.dart';
import 'package:baiqavisit/data/repositories/logout_repository.dart';
import 'package:baiqavisit/domain/models/login/login_event.dart';
import 'package:baiqavisit/domain/models/logout/logout_event.dart';
import 'package:baiqavisit/domain/models/profile/profile_event.dart';
import 'package:baiqavisit/domain/models/theme/app_theme_mode.dart';
import 'package:baiqavisit/domain/stream_controllers/app_theme_mode_stream_controller.dart';
import 'package:baiqavisit/domain/stream_controllers/login_event_stream_controller.dart';
import 'package:baiqavisit/domain/stream_controllers/logout_event_stream_controller.dart';
import 'package:baiqavisit/domain/stream_controllers/profile_event_stream_controller.dart';
import 'package:baiqavisit/presentation/application/di/get_it_injection.dart';
import 'package:baiqavisit/presentation/router/app_router.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:baiqavisit/presentation/support/state_message/state_message.dart';
import 'package:baiqavisit/presentation/support/state_message/state_message_manager.dart';
import 'package:baiqavisit/presentation/support/state_message/state_snack_bar_exts.dart';
import 'package:baiqavisit/presentation/widgets/button/custom_elevated_button.dart';
// import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class Application extends StatefulWidget {
  const Application({
    super.key,
  });

  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  final LoginEventStreamController _loginEventStreamController = getIt.get();
  final ProfileEventStreamController _profileEventStreamController =
      getIt.get();
  final LogoutEventStreamController _logoutEventStreamController = getIt.get();
  final AppThemeModeStreamController _appThemeModeStreamController =
      getIt.get();

  final LogoutRepository _logoutRepository = getIt.get();

  final AuthPreferences _authPreferences = getIt.get();
  final FcmTokenPreferences _fcmTokenPreferences = getIt.get();
  final LanguagePreferences _languagePreferences = getIt.get();
  final PinCodePreferences _pinCodePreferences = getIt.get();
  final ThemeModePreferences _themeModePreferences = getIt.get();

  late ThemeMode _themeMode;

  StreamSubscription<LoginEvent>? _loginSubscription;
  StreamSubscription<ProfileEvent>? _profileSubscription;
  StreamSubscription<LogoutEvent>? _logoutSubscription;
  StreamSubscription<AppThemeMode>? _themeSubscription;

  final _appRouter = AppRouter();

  @override
  void initState() {
    super.initState();

    _loginSubscription?.cancel();
    _loginSubscription = _loginEventStreamController.listen((event) async {
      if (event == LoginEvent.onLoginWithAccount) {
        // _checkAndGetFcmToken();
      }
    });

    _profileSubscription?.cancel();
    _profileSubscription = _profileEventStreamController.listen((event) async {
      if (event == ProfileEvent.onChangePassword) {
        // _checkAndGetFcmToken();
      }
    });

    _logoutSubscription?.cancel();
    _logoutSubscription = _logoutEventStreamController.listen((event) async {
      _deactivateFcmToken();

      await _logoutRepository.clearBeforeLogout();

      if (event == LogoutEvent.onTokenExpired) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // _appRouter.root.pushAndPopUntil(LoginRoute(), predicate: (_) => false);
        });
      }
    });
    _themeMode = _themeModePreferences.appThemeMode.themeMode;
    _themeSubscription = _appThemeModeStreamController.listen((event) {
      setState(() {
        _themeMode = event.themeMode;
      });
    });

    _prepareTokenHolder();
    //
    // _checkAndGetFcmToken();
    // _listerFcmTokenRefreshing();
  }

  @override
  void dispose() {
    _loginSubscription?.cancel();
    _logoutSubscription?.cancel();
    _themeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode ? Colors.white : Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.dark : Brightness.light,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Browser tab title; Flutter clears the one from index.html otherwise.
      title: 'NurNova AI',
      home: Stack(
        children: [
          MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'NurNova AI',
            theme: ThemeData(
              fontFamily: 'Inter',
              useMaterial3: false,
              colorScheme: _getLightModeColorScheme(),
            ),
            darkTheme: ThemeData(
              fontFamily: 'Inter',
              useMaterial3: false,
              brightness: Brightness.dark,
              colorScheme: _getDarkModeColorScheme(),
            ),
            themeMode: _themeMode,
            routerConfig: _appRouter.config(
              deepLinkBuilder: (_) => DeepLink(_getInitialRoutes()),
              // navigatorObservers: () => [ChuckerFlutter.navigatorObserver],
            ),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
          ),
          Builder(
            builder: (context) {
              _initStateMessageManager(context);

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  List<PageRouteInfo> _getInitialRoutes() {

    // if (_languagePreferences.isLanguageNotSelected) {
    //   return [const SetLanguageRoute()];
    // }
    return [HomeRoute()];
    // if (_authPreferences.isNotAuthorized) {
    //   return [LoginRoute()];
    // }

    // if (_pinCodePreferences.isPinNotSet) {
    //   return [SetPinCodeRoute(launchType: SetPinCodeLaunchType.launchForSet)];
    // }
    //
    // return [
    //   CheckPinCodeRoute(launchType: CheckPinCodeLaunchType.launchForCheck)
    // ];
  }

  void _prepareTokenHolder() {
    TokenHolder.fcmToken = _fcmTokenPreferences.fcmToken;
    TokenHolder.accessToken = _authPreferences.accessToken;
  }

  // Future<void> _checkAndGetFcmToken() async {
  //   try {
  //     if (_fcmTokenPreferences.isFcmTokenTaken) {
  //       if (_fcmTokenPreferences.isFcmTokenNotSent) {
  //         _activateFcmToken();
  //       }
  //
  //       return;
  //     } else {
  //       /**
  //        *  Force deleting fcm token for get new token each time
  //        * */
  //       await FirebaseMessaging.instance.deleteToken();
  //
  //       /**
  //        * Taking fcm token
  //        * */
  //       final fcmToken = await FirebaseMessaging.instance.getToken();
  //       Logger().wtf("_checkAndGetFcmToken taken token = $fcmToken");
  //       if (fcmToken != null) {
  //         _fcmTokenPreferences.setFcmToken(fcmToken);
  //         _activateFcmToken();
  //       }
  //       return;
  //     }
  //   } catch (e) {
  //     Logger().wtf("Error getting FCM token: $e");
  //     return;
  //   }
  // }

  // Future<void> _listerFcmTokenRefreshing() async {
  //   try {
  //     FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
  //       Logger().wtf("Token refreshed new fcm token: $fcmToken");
  //       _fcmTokenPreferences.setFcmToken(fcmToken);
  //       _activateFcmToken();
  //     });
  //     return;
  //   } catch (e) {
  //     Logger().wtf("Error getting FCM token: $e");
  //     return;
  //   }
  // }

  void _activateFcmToken() {
    if (_authPreferences.isNotAuthorized) {
      return;
    }

    // _fcmTokenRepository
    //     .activateFcmToken()
    //     .initFuture()
    //     .onStart(() {})
    //     .onSuccess((data) {})
    //     .onError((error) {})
    //     .onFinished(() {})
    //     .executeFuture();
  }

  void _deactivateFcmToken() {
    // _fcmTokenRepository
    //     .deactivateFcmToken()
    //     .initFuture()
    //     .onStart(() {})
    //     .onSuccess((data) {})
    //     .onError((error) {})
    //     .onFinished(() {})
    //     .executeFuture();
  }

  void _initStateMessageManager(BuildContext context) {
    final stateMessageManager = getIt<StateMessageManager>();

    stateMessageManager.setListeners(
      onShowBottomSheet: (m) => showStateMessageBottomSheet(context, m),
      onShowSnackBar: (m) => context.showStateMessageSnackBar(m),
    );
  }

  ColorScheme _getLightModeColorScheme() {
    return ColorScheme.fromSwatch(brightness: Brightness.light).copyWith(
      primary: Color(0xFF4393C7),
      secondary: Color(0xFFFFFFFF),
      background: Color(0xFFFFFFFF),
      onBackground: Color(0xFF000000),
      surface: Color(0xFFF3F3F3),
      onSurface: Color(0xFF000000),
    );
  }

  ColorScheme _getDarkModeColorScheme() {
    return ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
      primary: Color(0xFF4393C7),
      secondary: Color(0xFF000000),
      background: Color(0xFF121212),
      onBackground: Color(0xFFE0E0E0),
      surface: Color(0xFF333333),
      onSurface: Color(0xFFE0E0E0),
    );
  }

  void showStateMessageBottomSheet(BuildContext context, StateMessage message) {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (BuildContext buildContext) {
        return Material(
          color: context.bottomSheetColor,
          child: Container(
            color: context.bottomSheetColor,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 30),
                Center(child: message.titleOrDefault.s(22).w(600)),
                SizedBox(height: 14),
                message.message.s(16).w(500).copyWith(
                      maxLines: 5,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                SizedBox(height: 32),
                CustomElevatedButton(
                  text: Strings.closeTitle,
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Navigator.pop(buildContext);
                  },
                  backgroundColor: context.colors.buttonPrimary,
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
