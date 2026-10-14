import 'package:flutter/foundation.dart';

/// Нативное приложение на компьютере, а не браузер.
bool get isDesktop =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux);

/// Интерфейс сайта: в браузере и на компьютере. Windows-версия — это тот же
/// сайт, только распознавание и камера у неё свои, нативные, вместо
/// браузерных. Телефонный интерфейс с ML Kit — только на телефоне.
bool get usesWebLayout => kIsWeb || isDesktop;
