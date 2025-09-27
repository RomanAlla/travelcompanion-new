import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
  });
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;

  static Future<void> preload({
    required String imageUrl,
    required BuildContext context,
  }) async {
    try {
      await precacheImage(
        CachedNetworkImageProvider(imageUrl, cacheKey: 'unique_key_$imageUrl'),
        context,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> preloadMultiple({
    required List<String> imageUrls,
    required BuildContext context,
    int delayBetween = 50,
  }) async {
    for (final url in imageUrls) {
      if (!context.mounted) return;
      await preload(imageUrl: url, context: context);
      await Future.delayed(Duration(milliseconds: delayBetween));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => _defaultPlaceholder(),
      errorWidget: (context, url, error) => _defaultErrorWidget(),
      fit: fit,
      height: height,
      width: width,

      cacheKey: 'unique_key_$imageUrl',
    );
  }

  Widget _defaultPlaceholder() => Container(
    color: Colors.grey[200],
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
  );

  Widget _defaultErrorWidget() => Container(
    color: Colors.grey[200],
    child: Icon(Icons.broken_image, color: Colors.grey[400]),
  );
}
