import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/data/cache/preloaded_cached_image_provider.dart';
import 'package:travelcompanion/core/presentation/providers/data_providers.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/average_rating_provider.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/average_user_routes_rating.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/comments_count_provider.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/comments_provider.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/user_routes_count_provider.dart';
import 'package:travelcompanion/features/details_route/presentation/screens/route_description_content.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/bottom_sheet.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';

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
  bool _isPreloading = true;

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

  Future<void> _preloadImages() async {
    if (widget.route.photoUrls.isEmpty) {
      setState(() => _isPreloading = false);
      return;
    }

    await InstantAppCachedImage.preloadMultiple(widget.route.photoUrls);

    setState(() => _isPreloading = false);
  }

  @override
  void initState() {
    super.initState();

    myItems = widget.route.photoUrls
        .map((url) => InstantAppCachedImage(imageUrl: url, fit: BoxFit.cover))
        .toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isPreloading) {
      return _buildPreloader();
    }

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

  Widget _buildPreloader() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Загружаем маршрут...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
