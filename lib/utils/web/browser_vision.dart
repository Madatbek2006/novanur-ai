export 'browser_vision_models.dart';
// В браузере — JavaScript (web/vision/nurnova_vision.js), на компьютере —
// нативные библиотеки с тем же API.
export 'browser_vision_stub.dart'
    if (dart.library.js_interop) 'browser_vision_web.dart'
    if (dart.library.ffi) 'browser_vision_native.dart';
