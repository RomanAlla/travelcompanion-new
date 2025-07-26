import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

@RoutePage()
class FullScreenCommentPhotosScreen extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;
  const FullScreenCommentPhotosScreen({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController(initialPage: initialIndex);
    return Scaffold(
      body: PageView.builder(
        controller: controller,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return PhotoView(imageProvider: NetworkImage(imageUrls[index]));
        },
      ),
    );
  }
}
