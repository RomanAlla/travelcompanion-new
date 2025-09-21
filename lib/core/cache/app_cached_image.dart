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

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => _defaultPlaceholder(),
      errorWidget: (context, url, error) => _defaultErrorWidget(),
      fit: fit,
      height: height,
      width: width,
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
