import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

/// Тонкая обёртка над C API onnxruntime для десктопа.
///
/// Берём тот onnxruntime, что везёт с собой sherpa-onnx для узбекского
/// голоса (`onnxruntime.dll`, 1.28): своего в приложении нет нарочно — вторая
/// DLL с тем же именем, но другой версии сломала бы голос.
///
/// C API — это структура указателей на функции. Номера взяты разбором
/// `onnxruntime_c_api.h` (ORT_API_VERSION 28): структура только дополняется
/// в конце, так что номера ранних функций одинаковы во всех версиях.
class OnnxSession {
  OnnxSession._(this._api, this._env, this._session, this._memory);

  /// Открывает модель из байтов. [library] — путь к onnxruntime, если он не
  /// лежит рядом с программой (проверки на маке).
  factory OnnxSession.fromBytes(
    Uint8List model, {
    int threads = 4,
    String? library,
  }) {
    final api = _OrtApi.load(library);
    return using((arena) {
      final env = arena<Pointer<Void>>();
      api.check(api.createEnv(_warning, 'nurnova'.toNativeUtf8(allocator: arena), env));

      final options = arena<Pointer<Void>>();
      api.check(api.createSessionOptions(options));
      api.check(api.setIntraOpNumThreads(options.value, threads));
      api.check(api.setGraphOptimizationLevel(options.value, _enableAll));

      final bytes = arena<Uint8>(model.length);
      bytes.asTypedList(model.length).setAll(0, model);
      final session = arena<Pointer<Void>>();
      try {
        api.check(api.createSessionFromArray(
            env.value, bytes.cast(), model.length, options.value, session));
      } finally {
        api.releaseSessionOptions(options.value);
      }

      final memory = arena<Pointer<Void>>();
      api.check(api.createCpuMemoryInfo(_arenaAllocator, _memTypeDefault, memory));
      return OnnxSession._(api, env.value, session.value, memory.value);
    });
  }

  final _OrtApi _api;
  final Pointer<Void> _env;
  final Pointer<Void> _session;
  final Pointer<Void> _memory;

  /// Один вход float32 [shape] → один выход float32 из [outputLength] чисел.
  Float32List run({
    required String input,
    required Float32List data,
    required List<int> shape,
    required String output,
    required int outputLength,
  }) {
    return using((arena) {
      final buffer = arena<Float>(data.length);
      buffer.asTypedList(data.length).setAll(0, data);
      final dims = arena<Int64>(shape.length);
      for (var i = 0; i < shape.length; i++) {
        dims[i] = shape[i];
      }

      final value = arena<Pointer<Void>>();
      _api.check(_api.createTensor(_memory, buffer.cast(), data.length * 4, dims,
          shape.length, _float, value));

      final inputNames = arena<Pointer<Utf8>>()..value = input.toNativeUtf8(allocator: arena);
      final outputNames = arena<Pointer<Utf8>>()..value = output.toNativeUtf8(allocator: arena);
      final outputs = arena<Pointer<Void>>()..value = nullptr;
      try {
        _api.check(_api.run(_session, nullptr, inputNames, value, 1, outputNames, 1, outputs));
        final out = arena<Pointer<Void>>();
        _api.check(_api.getTensorMutableData(outputs.value, out));
        return Float32List.fromList(out.value.cast<Float>().asTypedList(outputLength));
      } finally {
        _api.releaseValue(value.value);
        if (outputs.value != nullptr) _api.releaseValue(outputs.value);
      }
    });
  }

  void close() {
    _api.releaseMemoryInfo(_memory);
    _api.releaseSession(_session);
    _api.releaseEnv(_env);
  }
}

const _warning = 2; // ORT_LOGGING_LEVEL_WARNING
const _enableAll = 99; // ORT_ENABLE_ALL
const _arenaAllocator = 1; // OrtArenaAllocator
const _memTypeDefault = 0; // OrtMemTypeDefault
const _float = 1; // ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT

typedef _Status = Pointer<Void>;

final class _OrtApiBase extends Struct {
  external Pointer<NativeFunction<Pointer<Pointer<Void>> Function(Uint32)>> getApi;
  external Pointer<NativeFunction<Pointer<Utf8> Function()>> getVersionString;
}

class _OrtApi {
  _OrtApi(Pointer<Pointer<Void>> api)
      : getErrorMessage = api[2]
            .cast<NativeFunction<Pointer<Utf8> Function(_Status)>>()
            .asFunction<Pointer<Utf8> Function(_Status)>(),
        createEnv = api[3]
            .cast<NativeFunction<_Status Function(Int32, Pointer<Utf8>, Pointer<Pointer<Void>>)>>()
            .asFunction<_Status Function(int, Pointer<Utf8>, Pointer<Pointer<Void>>)>(),
        createSessionFromArray = api[8]
            .cast<
                NativeFunction<
                    _Status Function(Pointer<Void>, Pointer<Void>, Size, Pointer<Void>,
                        Pointer<Pointer<Void>>)>>()
            .asFunction<
                _Status Function(
                    Pointer<Void>, Pointer<Void>, int, Pointer<Void>, Pointer<Pointer<Void>>)>(),
        run = api[9]
            .cast<
                NativeFunction<
                    _Status Function(Pointer<Void>, Pointer<Void>, Pointer<Pointer<Utf8>>,
                        Pointer<Pointer<Void>>, Size, Pointer<Pointer<Utf8>>, Size,
                        Pointer<Pointer<Void>>)>>()
            .asFunction<
                _Status Function(Pointer<Void>, Pointer<Void>, Pointer<Pointer<Utf8>>,
                    Pointer<Pointer<Void>>, int, Pointer<Pointer<Utf8>>, int,
                    Pointer<Pointer<Void>>)>(),
        createSessionOptions = api[10]
            .cast<NativeFunction<_Status Function(Pointer<Pointer<Void>>)>>()
            .asFunction<_Status Function(Pointer<Pointer<Void>>)>(),
        setGraphOptimizationLevel = api[23]
            .cast<NativeFunction<_Status Function(Pointer<Void>, Int32)>>()
            .asFunction<_Status Function(Pointer<Void>, int)>(),
        setIntraOpNumThreads = api[24]
            .cast<NativeFunction<_Status Function(Pointer<Void>, Int32)>>()
            .asFunction<_Status Function(Pointer<Void>, int)>(),
        createTensor = api[49]
            .cast<
                NativeFunction<
                    _Status Function(Pointer<Void>, Pointer<Void>, Size, Pointer<Int64>, Size,
                        Int32, Pointer<Pointer<Void>>)>>()
            .asFunction<
                _Status Function(Pointer<Void>, Pointer<Void>, int, Pointer<Int64>, int, int,
                    Pointer<Pointer<Void>>)>(),
        getTensorMutableData = api[51]
            .cast<NativeFunction<_Status Function(Pointer<Void>, Pointer<Pointer<Void>>)>>()
            .asFunction<_Status Function(Pointer<Void>, Pointer<Pointer<Void>>)>(),
        createCpuMemoryInfo = api[69]
            .cast<NativeFunction<_Status Function(Int32, Int32, Pointer<Pointer<Void>>)>>()
            .asFunction<_Status Function(int, int, Pointer<Pointer<Void>>)>(),
        releaseEnv = _release(api[92]),
        releaseStatus = _release(api[93]),
        releaseMemoryInfo = _release(api[94]),
        releaseSession = _release(api[95]),
        releaseValue = _release(api[96]),
        releaseSessionOptions = _release(api[100]);

  /// Версия API, которую просим. Нужные функции есть с самых ранних версий,
  /// так что подойдёт любой onnxruntime новее 1.14.
  static const _apiVersion = 14;

  static _OrtApi load(String? library) {
    final lib = DynamicLibrary.open(library ??
        (Platform.isWindows
            ? 'onnxruntime.dll'
            : Platform.isMacOS
                ? 'libonnxruntime.dylib'
                : 'libonnxruntime.so'));
    final base = lib
        .lookupFunction<Pointer<_OrtApiBase> Function(), Pointer<_OrtApiBase> Function()>(
            'OrtGetApiBase')();
    final api = base.ref.getApi
        .asFunction<Pointer<Pointer<Void>> Function(int)>()(_apiVersion);
    if (api == nullptr) throw StateError('onnxruntime слишком старый');
    return _OrtApi(api);
  }

  static void Function(Pointer<Void>) _release(Pointer<Void> fn) =>
      fn.cast<NativeFunction<Void Function(Pointer<Void>)>>().asFunction();

  final Pointer<Utf8> Function(_Status) getErrorMessage;
  final _Status Function(int, Pointer<Utf8>, Pointer<Pointer<Void>>) createEnv;
  final _Status Function(Pointer<Void>, Pointer<Void>, int, Pointer<Void>, Pointer<Pointer<Void>>)
      createSessionFromArray;
  final _Status Function(Pointer<Void>, Pointer<Void>, Pointer<Pointer<Utf8>>, Pointer<Pointer<Void>>, int,
      Pointer<Pointer<Utf8>>, int, Pointer<Pointer<Void>>) run;
  final _Status Function(Pointer<Pointer<Void>>) createSessionOptions;
  final _Status Function(Pointer<Void>, int) setGraphOptimizationLevel;
  final _Status Function(Pointer<Void>, int) setIntraOpNumThreads;
  final _Status Function(Pointer<Void>, Pointer<Void>, int, Pointer<Int64>, int, int, Pointer<Pointer<Void>>)
      createTensor;
  final _Status Function(Pointer<Void>, Pointer<Pointer<Void>>) getTensorMutableData;
  final _Status Function(int, int, Pointer<Pointer<Void>>) createCpuMemoryInfo;
  final void Function(Pointer<Void>) releaseEnv;
  final void Function(Pointer<Void>) releaseStatus;
  final void Function(Pointer<Void>) releaseMemoryInfo;
  final void Function(Pointer<Void>) releaseSession;
  final void Function(Pointer<Void>) releaseValue;
  final void Function(Pointer<Void>) releaseSessionOptions;

  /// Ошибка onnxruntime — исключением с её текстом.
  void check(_Status status) {
    if (status == nullptr) return;
    final message = getErrorMessage(status).toDartString();
    releaseStatus(status);
    throw StateError('onnxruntime: $message');
  }
}
