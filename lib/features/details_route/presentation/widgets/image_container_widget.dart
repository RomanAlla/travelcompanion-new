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
      // child: Image.network(
      //   url,
      //   fit: BoxFit.cover,
      //   loadingBuilder: (context, child, loadingProgress) {
      //     if (loadingProgress == null) return child;
      //     return Container(
      //       height: 200,
      //       color: Colors.grey[50],
      //       child: Center(
      //         child: CircularProgressIndicator(
      //           value: loadingProgress.expectedTotalBytes != null
      //               ? loadingProgress.cumulativeBytesLoaded /
      //                     loadingProgress.expectedTotalBytes!
      //               : null,
      //           color: Colors.grey[600],
      //         ),
      //       ),
      //     );
      //   },
      //   errorBuilder: (context, error, stackTrace) {
      //     return Container(
      //       height: 200,
      //       color: Colors.grey[50],
      //       child: Center(
      //         child: Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             Icon(Icons.error_outline, color: Colors.grey[400], size: 32),
      //             const SizedBox(height: 8),
      //             Text(
      //               'Ошибка загрузки изображения',
      //               style: TextStyle(color: Colors.grey[600]),
      //             ),
      //           ],
      //         ),
      //       ),
      //     );
      //   },
      // ),
    );
  }
}
