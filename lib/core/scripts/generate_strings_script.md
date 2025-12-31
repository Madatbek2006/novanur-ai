
# 🔤 generate_strings_script.dart

# This documentation describes the purpose, usage, and workflow of the Dart script
# used to generate localization string classes.

## 📍 Location
# `lib/core/scripts/generate_strings_script.dart`

## Usage:
```bash
dart generate_strings_script.dart
```

## 🛠️ Requirements:
- `easy_localization` must be included in `pubspec.yaml`

## 📄 Description

##  Step 1: Sorts all keys by alphabetically order in localization JSON files before code generation

##  Step 2: Runs `easy_localization:generate` to extract keys from JSON files
# - Reads from: `assets/localization/*.json`
# - Outputs: `strings_locale_keys.g.dart`

##  Step 3: Converts snake_case keys to camelCase
# - Standardizes naming for Dart conventions

##  Step 4: Creates a `Strings` class
# - Each camelCase key becomes a static getter using `.tr()`
# - Provides a type-safe and IDE-friendly way to access localized strings

## 📂 Input:
# - `assets/localization/*.json`

## 📦 Output:
# - `lib/core/gen/localization/strings_locale_keys.g.dart`
# - `lib/core/gen/localization/strings.dart`
