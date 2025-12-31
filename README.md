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
