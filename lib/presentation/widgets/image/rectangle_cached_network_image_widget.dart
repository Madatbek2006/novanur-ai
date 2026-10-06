import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nurnova_ai/core/cache/CustomCacheManager.dart';
import 'package:nurnova_ai/data/datasource/network/constants/constants.dart';
import 'package:nurnova_ai/presentation/support/extensions/color_extension.dart';

class RectangleCachedNetworkImage extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final Widget? placeHolderIcon;
  final Widget? errorIcon;

  const RectangleCachedNetworkImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.placeHolderIcon,
    this.errorIcon,
  });

  @override
  Widget build(BuildContext context) {
    var actualUrl = image.contains("https://") || image.contains("http://")
        ? image
        : "${Constants.baseUrlForImage}$image";

    return CachedNetworkImage(
        width: width,
        height: height,
        imageUrl: actualUrl,
        cacheManager: CustomCacheManager.imageCacheManager,
        fadeInDuration: const Duration(milliseconds: 500),
        fadeOutDuration: const Duration(milliseconds: 300),
        imageBuilder: (context, imageProvider) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
        placeholder: (context, url) {
          // Logger().w("RectangleCachedNetworkImage url = $actualUrl");
          return Container(
            decoration: BoxDecoration(color: context.cardColor),
            child: placeHolderIcon != null
                ? Center(child: placeHolderIcon)
                : Center(),
          );
        },
        errorWidget: (context, url, error) {
          // Logger().w("RectangleCachedNetworkImage error = $error");
          return Container(
            decoration: BoxDecoration(color: context.cardColor),
            child: errorIcon != null ? Center(child: errorIcon) : Center(),
          );
        });
  }
}
