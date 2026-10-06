import 'package:easy_localization/easy_localization.dart';

abstract class Constants {
  // Both can be overridden at build time, e.g. for a web build served over
  // HTTPS (browsers block http:// and ws:// calls from https:// pages):
  //   --dart-define=API_BASE_URL=https://api.example.com/
  //   --dart-define=WS_BASE_URL=wss://api.example.com/
  static const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');
  static const String _wsBaseUrlOverride = String.fromEnvironment('WS_BASE_URL');

  // static String baseUrl = 'https://vqa.jprq.live/';
  static String baseUrl = _apiBaseUrlOverride.isNotEmpty
      ? _apiBaseUrlOverride
      : 'https://glass-override-unpaved.ngrok-free.dev/';
  static String baseUrlWs = _wsBaseUrlOverride.isNotEmpty
      ? _wsBaseUrlOverride
      : _apiBaseUrlOverride.isNotEmpty
          ? _apiBaseUrlOverride.replaceFirst(RegExp('^http'), 'ws')
          : 'wss://glass-override-unpaved.ngrok-free.dev/';
  // static String baseUrl = 'http://81.17.102.235:8000/';
  static String baseUrlForImage = 'https://kindergarten2.istream.uz/';
  static var formatter = NumberFormat('###,000');
}
