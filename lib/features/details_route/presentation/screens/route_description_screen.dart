import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travelcompanion/features/details_route/data/models/comment_model.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/comment_rep_provider.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/bottom_sheet.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/carousel_slider_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/info_row_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/map_container.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/route_creator_info_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/route_description_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/route_meta_info_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/route_title_name_widget.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';
import 'package:travelcompanion/features/routes/presentation/providers/interesting_route_points_by_route_id_provider.dart';
import 'package:travelcompanion/features/routes/presentation/providers/route_repository_provider.dart';
import 'package:travelcompanion/features/routes/presentation/providers/tips_list_provider.dart';

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
  List<CommentModel>? commentsList;
  int? commentsCount;
  double? averageRating;
  int? userRoutesCount;
  double? averageUserRoutesRating;
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

  Future<void> getCommentsCount() async {
    try {
      final rep = ref.watch(commentRepositoryProvider);
      final count = await rep.getCommentsCount(routeId: widget.routeId);
      if (mounted) {
        setState(() {
          commentsCount = count;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getUserRoutesCount() async {
    try {
      final rep = ref.watch(routeRepositoryProvider);
      final count = await rep.getUserRoutesCount(
        creatorId: widget.route.creatorId,
      );
      setState(() {
        userRoutesCount = count;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getAverageUserRoutesRating() async {
    try {
      final rep = ref.watch(routeRepositoryProvider);
      final averageRating = await rep.getAverageUserRoutesRating(
        userId: widget.route.creatorId,
      );
      setState(() {
        averageUserRoutesRating = averageRating;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getAverageRating() async {
    try {
      final rep = ref.watch(commentRepositoryProvider);
      final rating = await rep.getAverageRating(routeId: widget.routeId);
      if (mounted) {
        setState(() {
          averageRating = rating;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getComments() async {
    try {
      final result = await ref
          .read(commentRepositoryProvider)
          .getComments(routeId: widget.route.id);
      if (mounted) {
        setState(() {
          commentsList = result;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getComments();
      getCommentsCount();
      getAverageRating();
      getUserRoutesCount();
      getAverageUserRoutesRating();
    });
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            CarouselSliderWidget(
              route: widget.route,
              items: myItems,
              count: myItems.length,
              activeIndex: currentIndex,
              ref: ref,
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Column(
                children: [
                  RouteTitleNameWidget(text: widget.route.name),
                  RouteMetaInfoWidget(
                    rating: averageRating ?? 0.0,
                    reviewsCount: commentsCount ?? 0,
                    routeType: widget.route.routeType,
                  ),
                  const SizedBox(height: 20),
                  RouteCreatorInfoWidget(
                    averageUserRoutesRating: averageUserRoutesRating ?? 0.0,
                    userRoutesCount: userRoutesCount ?? 0,
                    route: widget.route,
                    creatorName: widget.route.creator!.name!,
                  ),
                  const SizedBox(height: 20),
                  routeInfo(),
                  const SizedBox(height: 20),
                  const RouteDescriptionWidget(),
                  const SizedBox(height: 20),
                  MapContainer(route: widget.route),
                  const SizedBox(height: 20),
                  routePointsInfo(ref),
                  const SizedBox(height: 20),
                  routeTips(ref),
                  const SizedBox(height: 20),
                  reviewsSection(ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget routeTips(WidgetRef ref) {
    final tipsList = ref.watch(tipsListProvider(widget.routeId));
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: Text(
              'Советы и лайфхаки',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          tipsList.when(
            data: (tipsList) {
              if (tipsList.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.orange,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Нет советов',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: tipsList
                    .map(
                      (tip) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 4.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.orange,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tip.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            error: (error, _) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 8.0,
              ),
              child: Text(error.toString()),
            ),
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 8.0,
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Widget routePointsInfo(WidgetRef ref) {
    final pointsAsyncValue = ref.watch(
      interestingRoutePointsByRouteIdProvider(widget.routeId),
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Интересные точки маршрута',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          pointsAsyncValue.when(
            data: (pointsList) {
              if (pointsList.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5CE7).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 24,
                          color: Color(0xFF6C5CE7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Нет интересных точек',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: pointsList
                    .map(
                      (point) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C5CE7).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFF6C5CE7),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            point.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            point.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget routeInfo() {
    return const Row(
      children: [
        Expanded(
          child: Column(
            children: [
              InfoIconText(icon: Icons.directions_walk, label: 'fsdfsdf'),
            ],
          ),
        ),
        SizedBox(width: 7),
        Expanded(
          child: Column(
            children: [
              InfoIconText(icon: Icons.calendar_month, label: 'rweuyiruiweb'),
            ],
          ),
        ),
        SizedBox(width: 7),
        Expanded(
          child: Column(
            children: [InfoIconText(icon: Icons.timer, label: 'weropcxnmnmbv')],
          ),
        ),
        SizedBox(width: 7),
        Expanded(
          child: Column(
            children: [
              InfoIconText(icon: Icons.map, label: 'eqwriu0qwhjnbmmbnxc'),
            ],
          ),
        ),
      ],
    );
  }

  Widget reviewsSection(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Отзывы',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: showBottomSheet,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF6C5CE7),
                    size: 20,
                  ),
                  label: const Text(
                    'Добавить отзыв',
                    style: TextStyle(color: Color(0xFF6C5CE7)),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (commentsList == null)
            const Center(child: CircularProgressIndicator())
          else if (commentsList!.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23.0),
              child: Text(
                'Нет отзывов. Будьте первым!',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 23.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: commentsList!.length,
              itemBuilder: (context, index) {
                final comment = commentsList![index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: comment.creator?.avatarUrl != null
                                ? NetworkImage(comment.creator!.avatarUrl!)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.creator?.name ??
                                      'Пользователь ${comment.creatorId.substring(0, 6)}...',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < comment.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 18,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormat('dd.MM.yyyy').format(comment.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        comment.text,
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
