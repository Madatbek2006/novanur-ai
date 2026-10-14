// Голос работает через onnxruntime по FFI, а сайт собирается из того же кода
// и в браузере узбекский по-прежнему берёт с сервера — там заглушка.
export 'uzbek_voice_stub.dart' if (dart.library.ffi) 'uzbek_voice_native.dart';
