import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:image/image.dart' as img;
import 'package:nurnova_ai/utils/desktop/desktop_resources.dart';

/// Распознавание текста в десктопной версии — тот же Tesseract, что на сайте
/// (tesseract.js), только нативный: libtesseract через FFI, словари
/// tessdata_fast — uzb, rus, eng — в `data/desktop/tessdata`.
///
/// Распознаёт отдельный поток; ход работы главный поток читает с монитора
/// Tesseract, поэтому полоса «Распознаю NN%» идёт так же, как на сайте.
class DesktopOcr {
  Future<SendPort>? _worker;

  void preload() => _worker ??= _start();

  /// [languages] — коды Tesseract через «+», как у сайта: `uzb+rus`.
  Future<String> recognize(
    Uint8List encodedImage,
    String languages,
    void Function(String status, double progress) onProgress,
  ) async {
    final worker = await (_worker ??= _start());
    final tess = _Tesseract.load();
    final monitor = tess.monitorCreate();
    final reply = ReceivePort();
    worker.send((
      TransferableTypedData.fromList([encodedImage]),
      languages,
      monitor.address,
      reply.sendPort,
    ));

    onProgress(_status, 0);
    final ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      onProgress(_status, tess.monitorGetProgress(monitor).clamp(0, 100) / 100);
    });
    try {
      final (ok, text) = await reply.first as (bool, String);
      if (!ok) throw StateError(text);
      onProgress(_status, 1);
      return text;
    } finally {
      ticker.cancel();
      reply.close();
      // Монитор создаёт и удаляет главный поток: распознавание к этому
      // моменту закончилось, и читать его больше некому.
      tess.monitorDelete(monitor);
    }
  }

  Future<SendPort> _start() async {
    final ready = ReceivePort();
    await Isolate.spawn(
      _work,
      (ready.sendPort, desktopResource('tessdata')),
      debugName: 'desktop-ocr',
    );
    final reply = await ready.first;
    if (reply is! SendPort) {
      _worker = null;
      throw StateError('$reply');
    }
    return reply;
  }
}

/// Тот же статус, что шлёт tesseract.js: по нему панель текста показывает
/// проценты.
const _status = 'recognizing text';

void _work((SendPort, String) args) {
  final (main, tessdata) = args;
  final _Tesseract tess;
  try {
    tess = _Tesseract.load();
  } catch (e) {
    main.send('$e');
    return;
  }

  final api = tess.create();
  String? loaded; // языки, с которыми Tesseract сейчас поднят
  final requests = ReceivePort();
  main.send(requests.sendPort);

  requests.listen((message) {
    final (bytes, languages, monitor, reply) =
        message as (TransferableTypedData, String, int, SendPort);
    try {
      if (loaded != languages) {
        if (loaded != null) tess.end(api);
        final ok = using((arena) => tess.init2(
              api,
              tessdata.toNativeUtf8(allocator: arena),
              languages.toNativeUtf8(allocator: arena),
              _oemLstmOnly,
            ));
        if (ok != 0) throw StateError('Tesseract не поднялся с $languages');
        loaded = languages;
        tess.setPageSegMode(api, _psmAuto);
        using((arena) => tess.setVariable(api, 'user_defined_dpi'.toNativeUtf8(allocator: arena),
            '300'.toNativeUtf8(allocator: arena)));
      }

      final decoded = img.decodeImage(bytes.materialize().asUint8List());
      if (decoded == null) throw const FormatException('не картинка');
      final image = img.bakeOrientation(decoded).convert(numChannels: 4);
      final rgba = image.getBytes(order: img.ChannelOrder.rgba);

      final text = using((arena) {
        final pixels = arena<Uint8>(rgba.length);
        pixels.asTypedList(rgba.length).setAll(0, rgba);
        tess.setImage(api, pixels, image.width, image.height, 4, image.width * 4);
        if (tess.recognize(api, Pointer.fromAddress(monitor)) != 0) {
          throw StateError('Tesseract не распознал картинку');
        }
        final raw = tess.getUtf8Text(api);
        final result = raw.toDartString();
        tess.deleteText(raw);
        tess.clear(api);
        return result;
      });
      reply.send((true, text.trim()));
    } catch (e) {
      reply.send((false, '$e'));
    }
  });
}

const _oemLstmOnly = 1; // как у сайта: «OEM 1 = LSTM only»
const _psmAuto = 3;

/// Функции libtesseract, которые нужны распознаванию.
class _Tesseract {
  _Tesseract(DynamicLibrary lib)
      : create = lib.lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>(
            'TessBaseAPICreate'),
        init2 = lib.lookupFunction<
            Int32 Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>, Int32),
            int Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>, int)>('TessBaseAPIInit2'),
        setPageSegMode = lib.lookupFunction<Void Function(Pointer<Void>, Int32),
            void Function(Pointer<Void>, int)>('TessBaseAPISetPageSegMode'),
        setVariable = lib.lookupFunction<Int32 Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>),
            int Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)>('TessBaseAPISetVariable'),
        setImage = lib.lookupFunction<
            Void Function(Pointer<Void>, Pointer<Uint8>, Int32, Int32, Int32, Int32),
            void Function(Pointer<Void>, Pointer<Uint8>, int, int, int, int)>('TessBaseAPISetImage'),
        recognize = lib.lookupFunction<Int32 Function(Pointer<Void>, Pointer<Void>),
            int Function(Pointer<Void>, Pointer<Void>)>('TessBaseAPIRecognize'),
        getUtf8Text = lib.lookupFunction<Pointer<Utf8> Function(Pointer<Void>),
            Pointer<Utf8> Function(Pointer<Void>)>('TessBaseAPIGetUTF8Text'),
        deleteText = lib.lookupFunction<Void Function(Pointer<Utf8>),
            void Function(Pointer<Utf8>)>('TessDeleteText'),
        clear = lib.lookupFunction<Void Function(Pointer<Void>), void Function(Pointer<Void>)>(
            'TessBaseAPIClear'),
        end = lib.lookupFunction<Void Function(Pointer<Void>), void Function(Pointer<Void>)>(
            'TessBaseAPIEnd'),
        monitorCreate = lib.lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>(
            'TessMonitorCreate'),
        monitorDelete = lib.lookupFunction<Void Function(Pointer<Void>),
            void Function(Pointer<Void>)>('TessMonitorDelete'),
        monitorGetProgress = lib.lookupFunction<Int32 Function(Pointer<Void>),
            int Function(Pointer<Void>)>('TessMonitorGetProgress');

  /// libtesseract: на Windows — сборка UB-Mannheim рядом с программой, на маке
  /// для проверок — путь через `--dart-define=NURNOVA_TESSERACT=...`.
  static _Tesseract load() {
    const override = String.fromEnvironment('NURNOVA_TESSERACT');
    return _Tesseract(DynamicLibrary.open(override.isNotEmpty
        ? override
        : Platform.isWindows
            ? 'libtesseract-5.dll'
            : Platform.isMacOS
                ? 'libtesseract.5.dylib'
                : 'libtesseract.so.5'));
  }

  final Pointer<Void> Function() create;
  final int Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>, int) init2;
  final void Function(Pointer<Void>, int) setPageSegMode;
  final int Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>) setVariable;
  final void Function(Pointer<Void>, Pointer<Uint8>, int, int, int, int) setImage;
  final int Function(Pointer<Void>, Pointer<Void>) recognize;
  final Pointer<Utf8> Function(Pointer<Void>) getUtf8Text;
  final void Function(Pointer<Utf8>) deleteText;
  final void Function(Pointer<Void>) clear;
  final void Function(Pointer<Void>) end;
  final Pointer<Void> Function() monitorCreate;
  final void Function(Pointer<Void>) monitorDelete;
  final int Function(Pointer<Void>) monitorGetProgress;
}
