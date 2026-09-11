import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:nurnova_ai/core/extensions/text_extensions.dart';
import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/data/datasource/preference/auth_preferences.dart';
import 'package:nurnova_ai/data/datasource/preference/fcm_token_preferences.dart';
import 'package:nurnova_ai/data/datasource/preference/language_preferences.dart';
import 'package:nurnova_ai/data/datasource/preference/pin_code_preferences.dart';
import 'package:nurnova_ai/data/datasource/preference/theme_mode_preferences.dart';
import 'package:nurnova_ai/data/datasource/preference/token_holder.dart';
import 'package:nurnova_ai/data/repositories/logout_repository.dart';
import 'package:nurnova_ai/domain/models/login/login_event.dart';
import 'package:nurnova_ai/domain/models/logout/logout_event.dart';
import 'package:nurnova_ai/domain/models/profile/profile_event.dart';
import 'package:nurnova_ai/domain/models/theme/app_theme_mode.dart';
import 'package:nurnova_ai/domain/stream_controllers/app_theme_mode_stream_controller.dart';
import 'package:nurnova_ai/domain/stream_controllers/login_event_stream_controller.dart';
import 'package:nurnova_ai/domain/stream_controllers/logout_event_stream_controller.dart';
import 'package:nurnova_ai/domain/stream_controllers/profile_event_stream_controller.dart';
import 'package:nurnova_ai/presentation/application/di/get_it_injection.dart';
import 'package:nurnova_ai/presentation/router/app_router.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';
import 'package:nurnova_ai/presentation/support/state_message/state_message.dart';
import 'package:nurnova_ai/presentation/support/state_message/state_message_manager.dart';
import 'package:nurnova_ai/presentation/support/state_message/state_snack_bar_exts.dart';
import 'package:nurnova_ai/presentation/widgets/button/custom_elevated_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      home: Stack(
        children: [
          MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Inter',
              useMaterial3: false,
              scaffoldBackgroundColor: const Color(0xFFEEF2FF),
              colorScheme: _getLightModeColorScheme(),
            ),
            darkTheme: ThemeData(
              fontFamily: 'Inter',
              useMaterial3: false,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF0D1117),
              colorScheme: _getDarkModeColorScheme(),
            ),
            themeMode: _themeMode,
            routerConfig: _appRouter.config(
              deepLinkBuilder: (_) => DeepLink(_getInitialRoutes()),
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
    return [HomeRoute()];
  }

  void _prepareTokenHolder() {
    TokenHolder.fcmToken = _fcmTokenPreferences.fcmToken;
    TokenHolder.accessToken = _authPreferences.accessToken;
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
      primary: const Color(0xFF5B8DEF),
      secondary: const Color(0xFFFFFFFF),
      background: const Color(0xFFEEF2FF),
      onBackground: const Color(0xFF1A1D2E),
      surface: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF1A1D2E),
    );
  }

  ColorScheme _getDarkModeColorScheme() {
    return ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
      primary: const Color(0xFF6C9EFF),
      secondary: const Color(0xFF1A1D2E),
      background: const Color(0xFF0D1117),
      onBackground: const Color(0xFFE6EAF8),
      surface: const Color(0xFF161B27),
      onSurface: const Color(0xFFE6EAF8),
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
