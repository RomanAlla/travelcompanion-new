import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InstantAppCachedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const InstantAppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
  });

  static final Map<String, Uint8List?> _memoryCache = {};
  static final Set<String> _preloadedUrls = {};

  static ImageProvider getImageProvider(String url) {
    final cachedBytes = _memoryCache[url];
    if (cachedBytes != null) {
      return MemoryImage(cachedBytes);
    }

    return CachedNetworkImageProvider(url, cacheKey: 'instant_cache_$url');
  }

  static Future<void> preloadImage(String url) async {
    if (_preloadedUrls.contains(url)) return;

    try {
      final file = await DefaultCacheManager().getSingleFile(url);
      final bytes = await file.readAsBytes();
      _memoryCache[url] = bytes;
      _preloadedUrls.add(url);
    } catch (e) {
      debugPrint('Preload error: $e');
    }
  }

  static Future<void> preloadMultiple(List<String> urls) async {
    await Future.wait(urls.map(preloadImage));
  }

  static bool isPreloaded(String url) => _preloadedUrls.contains(url);

  @override
  State<InstantAppCachedImage> createState() => _InstantAppCachedImageState();
}

class _InstantAppCachedImageState extends State<InstantAppCachedImage> {
  late ImageProvider _imageProvider;
  bool _useMemoryImage = false;

  @override
  void initState() {
    super.initState();
    _initializeImageProvider();
  }

  void _initializeImageProvider() {
    final cachedBytes = InstantAppCachedImage._memoryCache[widget.imageUrl];

    if (cachedBytes != null) {
      _imageProvider = MemoryImage(cachedBytes);
      _useMemoryImage = true;
    } else {
      _imageProvider = CachedNetworkImageProvider(
        widget.imageUrl,
        cacheKey: 'cache_${widget.imageUrl}',
      );
      _useMemoryImage = false;

      _loadToMemory();
    }
  }

  Future<void> _loadToMemory() async {
    try {
      final file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
      final bytes = await file.readAsBytes();
      InstantAppCachedImage._memoryCache[widget.imageUrl] = bytes;
      InstantAppCachedImage._preloadedUrls.add(widget.imageUrl);
    } catch (e) {
      debugPrint('Memory load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: Image(
        image: _imageProvider,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (_useMemoryImage || wasSynchronouslyLoaded) {
            return child;
          }

          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: child,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.cumulativeBytesLoaded /
                    (loadingProgress.expectedTotalBytes ?? 1),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error_outline, color: Colors.grey),
          );
        },
      ),
    );
  }
}
