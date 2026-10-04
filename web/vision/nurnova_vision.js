/*
 * NurNova AI: in-browser helpers for the web build.
 *
 * The phone app reads text and finds objects with ML Kit, which does not run in
 * browsers. The web build uses:
 *   - text:     Tesseract.js (WebAssembly OCR)
 *   - barcodes: the browser's BarcodeDetector where it exists, otherwise ZXing
 *   - objects:  MediaPipe Object Detector (EfficientDet-Lite0, 80 COCO classes)
 * plus camera, file picking, drag-and-drop and paste helpers.
 *
 * Libraries are downloaded on first use. To self-host them, define
 * window.NURNOVA_VISION_CONFIG = { ...same keys as below } before this script.
 *
 * Everything that returns structured data returns a JSON string, so the Dart
 * side only needs plain String bindings.
 */
(function () {
  'use strict';

  var config = Object.assign({
    tesseract: 'https://cdn.jsdelivr.net/npm/tesseract.js@7.0.0/dist/tesseract.min.js',
    tesseractWorker: 'https://cdn.jsdelivr.net/npm/tesseract.js@7.0.0/dist/worker.min.js',
    tesseractCore: 'https://cdn.jsdelivr.net/npm/tesseract.js-core@7.0.0',
    // null: Tesseract.js fetches each language from @tesseract.js-data/<lang> on jsDelivr.
    tesseractLangPath: null,
    zxing: 'https://cdn.jsdelivr.net/npm/@zxing/library@0.23.0/umd/index.min.js',
    mediapipe: 'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@1.0.1/vision_bundle.js',
    mediapipeWasm: 'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@1.0.1/wasm',
    objectModel: 'https://storage.googleapis.com/mediapipe-models/object_detector/efficientdet_lite0/float16/1/efficientdet_lite0.tflite',
  }, window.NURNOVA_VISION_CONFIG || {});

  // ---------------------------------------------------------------- loading

  var scripts = {};

  function loadScript(src) {
    if (!scripts[src]) {
      scripts[src] = new Promise(function (resolve, reject) {
        var el = document.createElement('script');
        el.src = src;
        el.async = true;
        el.crossOrigin = 'anonymous';
        el.onload = function () { resolve(); };
        el.onerror = function () {
          delete scripts[src];
          el.remove();
          reject(new Error('Could not load ' + src));
        };
        document.head.appendChild(el);
      });
    }
    return scripts[src];
  }

  // Runs tasks one at a time; a failed task does not block the next one.
  function serial() {
    var tail = Promise.resolve();
    return function (task) {
      var run = tail.then(task, task);
      tail = run.catch(function () {});
      return run;
    };
  }

  // ----------------------------------------------------------------- images

  var workCanvas = document.createElement('canvas');

  function toBlob(canvas, type, quality) {
    return new Promise(function (resolve, reject) {
      canvas.toBlob(function (blob) {
        blob ? resolve(blob) : reject(new Error('encode_failed'));
      }, type, quality);
    });
  }

  async function decodeBitmap(bytes) {
    try {
      return await createImageBitmap(new Blob([bytes]));
    } catch (e) {
      throw new Error('decode_failed');
    }
  }

  // Draws `source` scaled so its longer side is at most maxSide.
  function drawScaled(source, width, height, maxSide, background) {
    var scale = Math.min(1, maxSide / Math.max(width, height));
    var w = Math.max(1, Math.round(width * scale));
    var h = Math.max(1, Math.round(height * scale));
    workCanvas.width = w;
    workCanvas.height = h;
    var ctx = workCanvas.getContext('2d', { willReadFrequently: true });
    if (background) {
      ctx.fillStyle = background;
      ctx.fillRect(0, 0, w, h);
    }
    ctx.drawImage(source, 0, 0, w, h);
    return workCanvas;
  }

  async function encodeJpeg(source, width, height, maxSide, quality) {
    // White behind transparent pixels: JPEG has no alpha and OCR wants dark-on-light.
    var canvas = drawScaled(source, width, height, maxSide, '#ffffff');
    var blob = await toBlob(canvas, 'image/jpeg', quality);
    return {
      bytes: new Uint8Array(await blob.arrayBuffer()),
      width: canvas.width,
      height: canvas.height,
    };
  }

  // Any browser-decodable image -> upright JPEG (EXIF rotation applied).
  async function normalizeImage(bytes, maxSide, quality) {
    var bitmap = await decodeBitmap(bytes);
    try {
      return await encodeJpeg(bitmap, bitmap.width, bitmap.height, maxSide, quality);
    } finally {
      bitmap.close();
    }
  }

  // ----------------------------------------------------------------- camera

  async function countCameras() {
    try {
      var devices = await navigator.mediaDevices.enumerateDevices();
      return devices.filter(function (d) { return d.kind === 'videoinput'; }).length;
    } catch (e) {
      return -1;
    }
  }

  async function cameraStatus() {
    if (!window.isSecureContext) return JSON.stringify({ status: 'insecure', cameras: 0 });
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      return JSON.stringify({ status: 'unsupported', cameras: 0 });
    }
    var cameras = await countCameras();
    if (cameras === 0) return JSON.stringify({ status: 'none', cameras: 0 });
    var state = 'prompt';
    try {
      // Firefox does not know the 'camera' permission name and throws.
      state = (await navigator.permissions.query({ name: 'camera' })).state;
    } catch (e) {}
    return JSON.stringify({ status: state, cameras: Math.max(cameras, 1) });
  }

  function cameraError(e) {
    switch (e && e.name) {
      case 'NotAllowedError':
      case 'PermissionDeniedError':
      case 'SecurityError':
        return 'denied';
      case 'NotFoundError':
      case 'DevicesNotFoundError':
      case 'OverconstrainedError':
        return 'none';
      case 'NotReadableError':
      case 'TrackStartError':
      case 'AbortError':
        return 'busy';
      default:
        return 'error';
    }
  }

  function prepareVideo(video) {
    video.muted = true;
    video.playsInline = true;
    video.setAttribute('playsinline', '');
    video.autoplay = true;
    video.style.width = '100%';
    video.style.height = '100%';
    video.style.objectFit = 'contain';
    video.style.background = '#000';
  }

  function stopCamera(video) {
    var stream = video && video.srcObject;
    if (stream && stream.getTracks) {
      stream.getTracks().forEach(function (track) { track.stop(); });
    }
    if (video) video.srcObject = null;
  }

  function waitForFrames(video) {
    if (video.videoWidth > 0) return Promise.resolve();
    return new Promise(function (resolve, reject) {
      var timer = setTimeout(function () { reject(new Error('timeout')); }, 10000);
      video.addEventListener('loadeddata', function () {
        clearTimeout(timer);
        resolve();
      }, { once: true });
    });
  }

  async function startCamera(video, facing) {
    var status = JSON.parse(await cameraStatus()).status;
    if (status === 'insecure' || status === 'unsupported' || status === 'none') {
      return JSON.stringify({ ok: false, error: status });
    }
    stopCamera(video);
    try {
      var stream = await navigator.mediaDevices.getUserMedia({
        audio: false,
        video: {
          facingMode: { ideal: facing || 'environment' },
          width: { ideal: 1920 },
          height: { ideal: 1080 },
        },
      });
      // A start that overlapped this one may have attached its stream already.
      stopCamera(video);
      prepareVideo(video);
      video.srcObject = stream;
      await video.play().catch(function () {});
      await waitForFrames(video);
      return JSON.stringify({
        ok: true,
        width: video.videoWidth,
        height: video.videoHeight,
        cameras: Math.max(await countCameras(), 1),
      });
    } catch (e) {
      stopCamera(video);
      return JSON.stringify({ ok: false, error: cameraError(e) });
    }
  }

  async function captureFrame(video, maxSide, quality) {
    if (!video || !video.videoWidth) return null;
    return encodeJpeg(video, video.videoWidth, video.videoHeight, maxSide, quality);
  }

  // ------------------------------------------------- picking, drop, paste

  function readFile(file) {
    return file.arrayBuffer().then(function (buffer) {
      return { name: file.name || 'image', type: file.type || '', bytes: new Uint8Array(buffer) };
    });
  }

  function pickImage() {
    return new Promise(function (resolve) {
      var input = document.createElement('input');
      input.type = 'file';
      input.accept = 'image/*';
      input.style.display = 'none';
      var settled = false;
      function finish(file) {
        if (settled) return;
        settled = true;
        input.remove();
        if (!file) return resolve(null);
        readFile(file).then(resolve, function () { resolve(null); });
      }
      input.addEventListener('change', function () { finish(input.files && input.files[0]); });
      input.addEventListener('cancel', function () { finish(null); });
      document.body.appendChild(input);
      input.click();
    });
  }

  var dropHandler = null;
  var dragHandler = null;
  var dragDepth = 0;
  var dropListenersInstalled = false;

  function carriesFiles(event) {
    var types = event.dataTransfer && event.dataTransfer.types;
    return !!types && Array.prototype.indexOf.call(types, 'Files') >= 0;
  }

  function setDragging(active) {
    if (dragHandler) dragHandler(active);
  }

  function deliver(file) {
    if (!dropHandler) return;
    var handler = dropHandler;
    readFile(file).then(handler, function () { handler(null); });
  }

  function clipboardImage(data) {
    var items = (data && data.items) || [];
    for (var i = 0; i < items.length; i++) {
      if (items[i].kind === 'file' && /^image\//.test(items[i].type)) return items[i].getAsFile();
    }
    return null;
  }

  function installDropListeners() {
    if (dropListenersInstalled) return;
    dropListenersInstalled = true;
    // Capture phase, and always cancel the default: otherwise a file dropped
    // outside the drop area makes the browser navigate away from the app.
    window.addEventListener('dragenter', function (e) {
      if (!carriesFiles(e)) return;
      e.preventDefault();
      if (dragDepth++ === 0) setDragging(true);
    }, true);
    window.addEventListener('dragover', function (e) {
      if (!carriesFiles(e)) return;
      e.preventDefault();
      e.dataTransfer.dropEffect = dropHandler ? 'copy' : 'none';
    }, true);
    window.addEventListener('dragleave', function (e) {
      if (!carriesFiles(e)) return;
      dragDepth = Math.max(0, dragDepth - 1);
      if (dragDepth === 0) setDragging(false);
    }, true);
    window.addEventListener('drop', function (e) {
      if (!carriesFiles(e)) return;
      e.preventDefault();
      dragDepth = 0;
      setDragging(false);
      var file = e.dataTransfer.files && e.dataTransfer.files[0];
      if (file) deliver(file);
    }, true);
    window.addEventListener('paste', function (e) {
      if (!dropHandler) return;
      var file = clipboardImage(e.clipboardData);
      if (!file) return; // plain text goes to the focused text field as usual
      e.preventDefault();
      deliver(file);
    }, true);
  }

  function setDropHandler(onFile, onDragChange) {
    installDropListeners();
    dropHandler = onFile;
    dragHandler = onDragChange;
  }

  function clearDropHandler() {
    dropHandler = null;
    dragHandler = null;
    dragDepth = 0;
  }

  // ------------------------------------------------------------------- text

  var ocrQueue = serial();
  var ocrWorker = null;
  var ocrLangs = null;
  var ocrProgress = null;

  async function ocrWorkerFor(langs) {
    if (ocrWorker && ocrLangs === langs) return ocrWorker;
    await loadScript(config.tesseract);
    if (ocrWorker) {
      var old = ocrWorker;
      ocrWorker = null;
      await old.terminate().catch(function () {});
    }
    var options = {
      workerPath: config.tesseractWorker,
      corePath: config.tesseractCore,
      logger: function (m) {
        if (ocrProgress) ocrProgress(String(m.status || ''), typeof m.progress === 'number' ? m.progress : 0);
      },
    };
    if (config.tesseractLangPath) options.langPath = config.tesseractLangPath;
    // OEM 1 = LSTM only: smaller core and the "best_int" language models.
    ocrWorker = await window.Tesseract.createWorker(langs.split('+'), 1, options);
    ocrLangs = langs;
    return ocrWorker;
  }

  function recognizeText(bytes, langs, onProgress) {
    return ocrQueue(async function () {
      ocrProgress = onProgress || null;
      try {
        var worker = await ocrWorkerFor(langs);
        var result = await worker.recognize(new Blob([bytes]));
        return (result.data && result.data.text) || '';
      } finally {
        ocrProgress = null;
      }
    });
  }

  // --------------------------------------------------------------- barcodes

  var nativeBarcodeDetector; // undefined: not checked yet, null: unavailable
  var zxingStill = null;
  var zxingLive = null;

  async function getNativeBarcodeDetector() {
    if (nativeBarcodeDetector !== undefined) return nativeBarcodeDetector;
    nativeBarcodeDetector = null;
    if ('BarcodeDetector' in window) {
      try {
        var formats = await window.BarcodeDetector.getSupportedFormats();
        if (formats && formats.length) nativeBarcodeDetector = new window.BarcodeDetector({ formats: formats });
      } catch (e) {}
    }
    return nativeBarcodeDetector;
  }

  async function getZxing(tryHarder) {
    await loadScript(config.zxing);
    var Z = window.ZXing;
    var reader = tryHarder ? zxingStill : zxingLive;
    if (!reader) {
      var F = Z.BarcodeFormat;
      var hints = new Map();
      hints.set(Z.DecodeHintType.POSSIBLE_FORMATS, [
        F.EAN_13, F.EAN_8, F.UPC_A, F.UPC_E, F.CODE_128, F.CODE_39, F.CODE_93,
        F.ITF, F.CODABAR, F.QR_CODE, F.DATA_MATRIX,
      ]);
      if (tryHarder) hints.set(Z.DecodeHintType.TRY_HARDER, true);
      reader = new Z.MultiFormatReader();
      reader.setHints(hints);
      if (tryHarder) zxingStill = reader; else zxingLive = reader;
    }
    return reader;
  }

  function zxingDecode(reader, canvas) {
    var Z = window.ZXing;
    try {
      var bitmap = new Z.BinaryBitmap(new Z.HybridBinarizer(new Z.HTMLCanvasElementLuminanceSource(canvas)));
      var result = reader.decodeWithState(bitmap);
      return {
        text: result.getText(),
        format: String(Z.BarcodeFormat[result.getBarcodeFormat()] || '').toLowerCase(),
      };
    } catch (e) {
      return null; // NotFound / Checksum / Format: nothing readable at this scale
    } finally {
      reader.reset();
    }
  }

  async function nativeDecode(source) {
    var detector = await getNativeBarcodeDetector();
    if (!detector) return null;
    try {
      var found = await detector.detect(source);
      if (found && found.length) return { text: found[0].rawValue, format: String(found[0].format || '') };
    } catch (e) {}
    return null;
  }

  async function decodeBarcodeFromImage(bytes) {
    var bitmap = await decodeBitmap(bytes);
    try {
      var hit = await nativeDecode(bitmap);
      if (!hit) {
        var reader = await getZxing(true);
        // Small codes need pixels, blurry ones read better downscaled.
        var sides = [1600, 2600, 900];
        for (var i = 0; i < sides.length && !hit; i++) {
          hit = zxingDecode(reader, drawScaled(bitmap, bitmap.width, bitmap.height, sides[i]));
        }
      }
      return hit ? JSON.stringify(hit) : null;
    } finally {
      bitmap.close();
    }
  }

  async function decodeBarcodeFromVideo(video) {
    if (!video || !video.videoWidth) return null;
    var hit = await nativeDecode(video);
    if (!hit) {
      var reader = await getZxing(false);
      hit = zxingDecode(reader, drawScaled(video, video.videoWidth, video.videoHeight, 1024));
    }
    return hit ? JSON.stringify(hit) : null;
  }

  // ---------------------------------------------------------------- objects

  var detectorQueue = serial();
  var detectorReady = null;
  var detectorMode = null;
  var lastVideoTimestamp = 0;

  function loadDetector() {
    if (!detectorReady) {
      detectorReady = (async function () {
        await loadScript(config.mediapipe);
        var fileset = await window.Vision.FilesetResolver.forVisionTasks(config.mediapipeWasm);
        var detector = await window.Vision.ObjectDetector.createFromOptions(fileset, {
          baseOptions: { modelAssetPath: config.objectModel, delegate: 'CPU' },
          runningMode: 'IMAGE',
          scoreThreshold: 0.45,
          maxResults: 15,
        });
        detectorMode = 'IMAGE';
        return detector;
      })();
      detectorReady.catch(function () { detectorReady = null; });
    }
    return detectorReady;
  }

  async function detectorFor(mode) {
    var detector = await loadDetector();
    if (detectorMode !== mode) {
      await detector.setOptions({ runningMode: mode });
      detectorMode = mode;
    }
    return detector;
  }

  function detectionsJson(result, width, height) {
    var objects = ((result && result.detections) || []).map(function (d) {
      var category = (d.categories && d.categories[0]) || {};
      var box = d.boundingBox || {};
      return {
        label: category.categoryName || '',
        score: category.score || 0,
        x: box.originX || 0,
        y: box.originY || 0,
        w: box.width || 0,
        h: box.height || 0,
      };
    });
    return JSON.stringify({ width: width, height: height, objects: objects });
  }

  function detectObjectsInImage(bytes) {
    return detectorQueue(async function () {
      var detector = await detectorFor('IMAGE');
      var bitmap = await decodeBitmap(bytes);
      try {
        return detectionsJson(detector.detect(bitmap), bitmap.width, bitmap.height);
      } finally {
        bitmap.close();
      }
    });
  }

  function detectObjectsInVideo(video) {
    return detectorQueue(async function () {
      if (!video || !video.videoWidth || video.readyState < 2) return null;
      var detector = await detectorFor('VIDEO');
      // detectForVideo needs strictly increasing timestamps.
      var now = Math.max(performance.now(), lastVideoTimestamp + 1);
      lastVideoTimestamp = now;
      return detectionsJson(detector.detectForVideo(video, now), video.videoWidth, video.videoHeight);
    });
  }

  // ---------------------------------------------------------------- preload

  // Starts downloading what a feature needs, so the first result comes faster.
  function preload(feature) {
    var ignore = function () {};
    if (feature.indexOf('text:') === 0) {
      var langs = feature.substring(5);
      ocrQueue(function () { return ocrWorkerFor(langs); }).catch(ignore);
    } else if (feature === 'barcode') {
      getNativeBarcodeDetector().then(function (native) {
        if (!native) return getZxing(true);
      }).catch(ignore);
    } else if (feature === 'objects') {
      loadDetector().catch(ignore);
    }
  }

  window.nurnovaVision = {
    cameraStatus: cameraStatus,
    prepareVideo: prepareVideo,
    startCamera: startCamera,
    stopCamera: stopCamera,
    captureFrame: captureFrame,
    normalizeImage: normalizeImage,
    pickImage: pickImage,
    setDropHandler: setDropHandler,
    clearDropHandler: clearDropHandler,
    recognizeText: recognizeText,
    decodeBarcodeFromImage: decodeBarcodeFromImage,
    decodeBarcodeFromVideo: decodeBarcodeFromVideo,
    detectObjectsInImage: detectObjectsInImage,
    detectObjectsInVideo: detectObjectsInVideo,
    preload: preload,
  };
})();
