import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager {
  static const keyCachedImages = 'cached-network-images';
  static CacheManager imageCacheManager = CacheManager(
    Config(
      keyCachedImages,
      stalePeriod: const Duration(days: 3), // Maximum saving days
      maxNrOfCacheObjects: 150, // Maximum number of files
      fileService: HttpFileService(), //
    ),
  );
}
