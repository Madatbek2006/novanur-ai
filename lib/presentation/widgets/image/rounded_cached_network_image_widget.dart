import 'package:baiqavisit/core/cache/CustomCacheManager.dart';
import 'package:baiqavisit/data/datasource/network/constants/constants.dart';
import 'package:baiqavisit/presentation/support/extensions/color_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class RoundedCachedNetworkImage extends StatelessWidget {
  const RoundedCachedNetworkImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.placeHolderIcon,
    this.errorIcon,
    this.borderRadius=360,
  });

  final String image;
  final double? height;
  final double? width;
  final Widget? placeHolderIcon;
  final Widget? errorIcon;
  final double borderRadius;

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
              borderRadius: BorderRadius.circular(borderRadius),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
        placeholder: (context, url) {
          // Logger().w("RoundedCachedNetworkImage url = $actualUrl");
          return Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: placeHolderIcon != null
                ? Center(child: placeHolderIcon)
                : Center(),
          );
        },
        errorWidget: (context, url, error) {
          // Logger().w("RoundedCachedNetworkImage error = $error");
          return Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: errorIcon != null ? Center(child: errorIcon) : Center(),
          );
        });
  }
}
