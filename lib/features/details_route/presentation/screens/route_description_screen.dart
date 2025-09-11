import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/average_rating_provider.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/average_user_routes_rating.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/comments_count_provider.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/comments_provider.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/user_routes_count_provider.dart';
import 'package:travelcompanion/features/details_route/presentation/screens/route_description_content.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/bottom_sheet.dart';
import 'package:travelcompanion/features/route_builder/data/models/route_model.dart';

@RoutePage()
class RouteDescriptionScreen extends ConsumerStatefulWidget {
  final RouteModel route;
  final String routeId;

  const RouteDescriptionScreen({
    super.key,
    required this.routeId,
    required this.route,
  });

  @override
  ConsumerState<RouteDescriptionScreen> createState() => _MyshiState();
}

class _MyshiState extends ConsumerState<RouteDescriptionScreen> {
  late final List<Widget> myItems;
  int currentIndex = 0;

  void showBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      elevation: 0,
      context: context,
      builder: (context) {
        return BottomSheetWidget(route: widget.route);
      },
    );
  }

  @override
  void initState() {
    super.initState();

    myItems = widget.route.photoUrls
        .map(
          (url) => SizedBox(
            width: double.infinity,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[50],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[50],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ошибка загрузки изображения',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.route.id));
    final commentsCountAsync = ref.watch(
      commentsCountProvider(widget.route.id),
    );
    final averageRatingAsync = ref.watch(
      averageRatingProvider(widget.route.id),
    );
    final userRoutesCountAsync = ref.watch(
      userRoutesCountProvider(widget.route.creatorId),
    );
    final averageUserRoutesRatingAsync = ref.watch(
      averageUserRoutesRatingProvider(widget.route.creator!.id),
    );
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RouteDescriptionContent(
        creator: widget.route.creator!,
        route: widget.route,
        myItems: myItems,
        currentIndex: currentIndex,
        commentsCount: commentsCountAsync.value,
        averageRating: averageRatingAsync.value,
        userRoutesCount: userRoutesCountAsync.value,
        averageUserRoutesRating: averageUserRoutesRatingAsync.value,
        commentsList: commentsAsync.value,
        onReviewPressed: showBottomSheet,
      ),
    );
  }
}
