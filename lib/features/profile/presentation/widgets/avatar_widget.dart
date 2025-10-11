import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/data/cache/preloaded_cached_image_provider.dart';

class AvatarWidget extends ConsumerWidget {
  final double? radius;
  final String? avatarUrl;
  const AvatarWidget({
    super.key,
    required this.radius,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: avatarUrl != null
          ? InstantAppCachedImage.getImageProvider(avatarUrl!)
          : null,
      child: avatarUrl == null ? Icon(Icons.add_a_photo) : null,
    );
  }
}
