import 'dart:convert';
import 'dart:io';

import 'package:nurnova_ai/core/gen/assets/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
extension XFileToBase64 on XFile {
  Future<String> toBase64() async {
    Logger().d("TTT => toBase64 path: $path");

    final file = File(path);
    final exists = await file.exists();
    Logger().d("TTT => файл существует: $exists");

    if (!exists) return '';

    try {
      final bytes = await readAsBytes();
      Logger().d("TTT => успешно прочитано: ${bytes.length} байт");
      return base64Encode(bytes);
    } catch (e, s) {
      Logger().e("TTT => ошибка при readAsBytes: $e\n$s");
      return '';
    }
  }
  Future<String> toBase64WithPrefix({String mimeType = 'image/jpeg'}) async {
    final bytes = await readAsBytes();
    final base64Str = base64Encode(bytes);
    return 'data:$mimeType;base64,$base64Str';
  }
}




extension SvgGenImageColor on SvgGenImage {
  static final _cache = <String, _SvgCache>{};
  static final _assetExistCache = <String, bool>{};



  Widget svgCustom({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    Color? color,
  }) {
    final cache = _cache.putIfAbsent(path, () {
      final suffixRegex = RegExp(r'(_dark|_light)(?=\.svg$)', caseSensitive: false);
      final hasSuffix = suffixRegex.hasMatch(path);
      final basePath = hasSuffix
          ? path.replaceAll(suffixRegex, '').replaceAll(RegExp(r'\.svg$', caseSensitive: false), '')
          : null;
      return _SvgCache(path, basePath, hasSuffix);
    });

    return Builder(
      builder: (context) {
        final themedPath = cache.hasThemedSuffix
            ? "${cache.basePath}${Theme.of(context).brightness == Brightness.dark ? '_dark.svg' : '_light.svg'}"
            : cache.originalPath;

        Widget buildSvg(String assetPath) => SvgPicture.asset(
          assetPath,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
        );

        if (!cache.hasThemedSuffix) return buildSvg(cache.originalPath);

        if (_assetExistCache.containsKey(themedPath)) {
          return buildSvg(_assetExistCache[themedPath]! ? themedPath : cache.originalPath);
        }

        return FutureBuilder<bool>(
          future: _assetExists(context, themedPath),
          builder: (context, snapshot) =>
              buildSvg((snapshot.data ?? true) ? themedPath : cache.originalPath),
        );
      },
    );
  }

  static Future<bool> _assetExists(BuildContext context, String assetPath) async {
    if (_assetExistCache.containsKey(assetPath)) return _assetExistCache[assetPath]!;
    try {
      await DefaultAssetBundle.of(context).load(assetPath);
      return _assetExistCache[assetPath] = true;
    } catch (_) {
      return _assetExistCache[assetPath] = false;
    }
  }
}


class _SvgCache {
  final String originalPath;
  final String? basePath;
  final bool hasThemedSuffix;
  _SvgCache(this.originalPath, this.basePath, this.hasThemedSuffix);
}
