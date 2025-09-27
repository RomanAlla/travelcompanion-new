import 'package:flutter/material.dart';
import 'package:travelcompanion/core/cache/app_cached_image.dart';

class ImageContainerWidget extends StatelessWidget {
  final String url;
  const ImageContainerWidget({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppCachedImage(imageUrl: url, fit: BoxFit.cover),
    );
  }
}
