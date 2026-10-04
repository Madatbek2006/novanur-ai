import 'package:flutter/foundation.dart';

// dart:io's Platform is unavailable in the browser, so read the target platform.
final bool _isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

final double bottomBarHeight = _isIOS ? 106 : 80;

final double defaultBottomPadding = _isIOS ? 36 : 24;
