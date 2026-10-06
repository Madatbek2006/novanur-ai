import 'package:nurnova_ai/data/datasource/network/constants/constants.dart';
import 'package:nurnova_ai/data/datasource/network/interceptor/dynamic_token_interceptor.dart';
import 'package:nurnova_ai/data/datasource/network/interceptor/common_interceptor.dart';
import 'package:nurnova_ai/data/datasource/network/interceptor/error_interceptor.dart';
import 'package:nurnova_ai/data/datasource/network/interceptor/fixed_token_interceptor.dart';
import 'package:nurnova_ai/data/datasource/network/interceptor/language_interceptor.dart';
import 'package:nurnova_ai/data/datasource/network/interceptor/refresh_token_interceptor.dart';
import 'package:nurnova_ai/data/datasource/network/services/photo_analysis_service.dart';
import 'package:nurnova_ai/data/datasource/network/services/speech_service.dart';
// import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

const String private = "dio_with_authorization";
const String public = "dio_without_authorization";
const String refresh = "dio_refresh_token";
const String fixed = "dio_with_fixed_token";

extension GetItModuleNetwork on GetIt {
  Future<void> networkModule() async {
    ///
    /// Base interceptors
    ///

    registerLazySingleton(() => CommonInterceptor());
    // registerLazySingleton(() => ChuckerDioInterceptor());
    registerLazySingleton(() => DynamicTokenInterceptor(get()));
    registerLazySingleton(() => FixedTokenInterceptor());
    registerLazySingleton(() => ErrorInterceptor());
    registerLazySingleton(() => LanguageInterceptor(get()));

    registerLazySingleton(
      () => InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          options.headers.addAll(<String, String>{});
          handler.next(options);
        },
      ),
    );
    registerLazySingleton(
      () => PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    DynamicTokenInterceptor dynamicTokenInterceptor = get();
    FixedTokenInterceptor fixedTokenInterceptor = get();
    CommonInterceptor commonInterceptor = get();
    LanguageInterceptor languageInterceptor = get();
    ErrorInterceptor errorInterceptor = get();
    InterceptorsWrapper headerInterceptor = get();
    PrettyDioLogger loggerInterceptor = get();
    // ChuckerDioInterceptor chuckerDioInterceptor = get();

    ///
    /// Refresh token interceptor
    ///

    registerSingleton<Dio>(
      provideDio(
        interceptors: [
          commonInterceptor,
          languageInterceptor,
          loggerInterceptor,
          // chuckerDioInterceptor,
          errorInterceptor,
          headerInterceptor,
        ],
      ),
      instanceName: refresh,
    );

    registerLazySingleton(
      () => RefreshTokenInterceptor(get(), get(instanceName: refresh), get()),
    );

    RefreshTokenInterceptor refreshTokenInterceptor = get();

    ///
    /// Public dio and services
    ///

    registerSingleton<Dio>(
      provideDio(
        interceptors: [
          commonInterceptor,
          languageInterceptor,
          loggerInterceptor,
          // chuckerDioInterceptor,
          errorInterceptor,
          headerInterceptor,
        ],
      ),
      instanceName: public,
    );


    ///
    /// Providing fixed dio and services
    ///

    registerSingleton<Dio>(
      provideDio(
        interceptors: [
          fixedTokenInterceptor,
          commonInterceptor,
          languageInterceptor,
          loggerInterceptor,
          // chuckerDioInterceptor,
          errorInterceptor,
          headerInterceptor,
        ],
      ),
      instanceName: fixed,
    );



    ///
    /// Providing private dio and services
    ///

    registerSingleton<Dio>(
      provideDio(
        interceptors: [
          dynamicTokenInterceptor,
          refreshTokenInterceptor,
          commonInterceptor,
          languageInterceptor,
          loggerInterceptor,
          // chuckerDioInterceptor,
          errorInterceptor,
          headerInterceptor,
        ],
      ),
      instanceName: private,
    );

    registerLazySingleton(() => PhotoAnalysisService(get(instanceName: private)));
    registerLazySingleton(() => SpeechService(get(instanceName: private)));

    await allReady();
  }
}

Dio provideDio({List<Interceptor> interceptors = const []}) {
  final Dio dio = Dio();

  final timeout = Duration(seconds: 120);
  final options = BaseOptions(
    baseUrl: Constants.baseUrl,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      // Бесплатный ngrok показывает браузерную заставку вместо ответа,
      // если не сказать ему, что клиент не браузер. На обычном сервере
      // заголовок просто игнорируется.
      'ngrok-skip-browser-warning': 'true',
    },
  );
  dio.options = options
    ..connectTimeout = timeout
    ..receiveTimeout = timeout
    ..sendTimeout = timeout;

  dio.interceptors.addAll(interceptors);

  return dio;
}
