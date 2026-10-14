// TFLite работает через FFI, а в браузере FFI нет. Сайт собирается из того же
// кода, поэтому там подставляется заглушка, а режим «Предметы дома» не
// показывается.
export 'home_object_detector_stub.dart'
    if (dart.library.ffi) 'home_object_detector_native.dart';
