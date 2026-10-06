## 🛠 Tooling Commands

# ⚙️ Runs code generation (freezed, json_serializable, etc.)
# Run after editing model classes or adding annotations like @freezed or @JsonSerializable.
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

# 🔤 Generates localized string accessors from .json files
# Run this after editing translation files in assets/localization.
```bash
dart lib/core/scripts/generate_strings_script.dart
```

# 📥 Pre-downloads Flutter SDK binaries and tools
# Use this after upgrading Flutter SDK or switching channels.
# Also helpful when build errors mention missing files like frontend_server.dart.snapshot or flutter_tool.
```bash
flutter precache
```

# 🧹 Cleans build artifacts and intermediate files
# Run this when build issues occur or after switching between Flutter SDK versions/channels.
```bash
flutter clean
```

# 📦 Installs project dependencies
# Run after adding or modifying dependencies in pubspec.yaml.
```bash
flutter pub get
```

# 🛠 Repairs corrupted or misbehaving packages in pub cache
# Use when packages act inconsistently or fail to resolve properly.
```bash
flutter pub cache repair
```

# 🧽 Removes all previously generated build_runner files
# Use this when generated code causes conflicts or is outdated.
```bash
flutter pub run build_runner clean
```

# ✅ Recommended Fix — Full Build Reset (when `build_runner` fails)
# If you encounter persistent `build_runner` errors (e.g. missing snapshot files or failed script pre-compilation),
# use the command below to remove cached build artifacts and lock files.
# After running this, make sure to call:
#   flutter clean
#   flutter pub get
#   dart run build_runner build --delete-conflicting-outputs

```bash
rm -rf .dart_tool .packages build pubspec.lock
```

## 🌐 Web version

The browser build has its own dashboard (`lib/presentation/features/web`) with the
same four tools. The picture can come from the camera, the file picker,
drag-and-drop or Ctrl+V, so it also works on computers without a camera.

| Tool | Phone app | Web |
|---|---|---|
| Scan text | ML Kit | Tesseract.js (Uzbek, Russian, English) |
| Scan barcode | mobile_scanner | Browser `BarcodeDetector` or ZXing, product from Open Food Facts; digits can also be typed in |
| Describe scene | AI chat (backend) | the same chat, next to the image |
| Object recognition | ML Kit | MediaPipe EfficientDet-Lite0 (80 COCO classes, names in uz/ru/en) |

The browser-side code is `web/vision/nurnova_vision.js`; Dart talks to it through
`lib/utils/web/browser_vision.dart`.

```bash
# run locally (localhost counts as secure, so the camera works)
flutter run -d chrome

# static site in build/web
flutter build web --release
```

### Before publishing

- **HTTPS.** Browsers only give the camera to `https://` pages (and localhost), and
  an `https://` page may not call `http://` or `ws://` addresses. The AI server
  (`http://81.17.102.235:8000`) therefore needs HTTPS/WSS, for example behind nginx
  with a certificate. Then point the build at it:
  ```bash
  flutter build web --release \
    --dart-define=API_BASE_URL=https://api.example.com/ \
    --dart-define=WS_BASE_URL=wss://api.example.com/
  ```
  Without `WS_BASE_URL` the WebSocket address is derived from `API_BASE_URL`.
- **CORS.** The AI server must allow the site's origin (`Access-Control-Allow-Origin`;
  with FastAPI that is `CORSMiddleware`). The web build does send its own headers —
  `Content-Type: application/json` and `ngrok-skip-browser-warning` — so the browser
  asks permission first with an `OPTIONS` request, and both headers have to be
  allowed along with `GET, POST, OPTIONS`. The backend already does this; list the
  site's address in `WEB_ORIGINS` in its `.env`, comma-separated. Addresses on
  `localhost` are allowed on any port, so `flutter run -d chrome` works as is.
- **Recognition libraries.** On first use the browser downloads Tesseract.js, ZXing and
  MediaPipe from jsDelivr and the object model from Google Storage (roughly 10 MB for
  text and 20 MB for objects, cached afterwards). To host them yourself, define
  `window.NURNOVA_VISION_CONFIG` in `web/index.html`; the keys are listed at the top of
  `web/vision/nurnova_vision.js`.

After pulling these changes, regenerate code (new route and state classes):
```bash
dart run build_runner build --delete-conflicting-outputs
dart lib/core/scripts/generate_strings_script.dart
```
