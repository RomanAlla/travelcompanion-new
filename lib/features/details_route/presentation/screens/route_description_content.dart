import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/entities/user_model.dart';
import 'package:travelcompanion/core/domain/entities/comment_model.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/carousel_slider_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/reviews_section_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/route_creator_info_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/route_description_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/route_meta_info_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/route_points_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/route_title_name_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/tips_widget.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart'
    show RouteModel;

class RouteDescriptionContent extends ConsumerStatefulWidget {
  final RouteModel route;
  final int? commentsCount;
  final double? averageRating;
  final int? userRoutesCount;
  final double? averageUserRoutesRating;
  final List<CommentModel>? commentsList;
  final VoidCallback? onReviewPressed;
  final List<Widget> myItems;
  final int currentIndex;
  final UserModel creator;
  const RouteDescriptionContent({
    super.key,
    required this.creator,
    required this.route,
    required this.commentsCount,
    required this.averageRating,
    required this.userRoutesCount,
    required this.averageUserRoutesRating,
    required this.commentsList,
    this.onReviewPressed,
    required this.myItems,
    required this.currentIndex,
  });

  @override
  ConsumerState<RouteDescriptionContent> createState() =>
      _RouteDescriptionContentState();
}

class _RouteDescriptionContentState
    extends ConsumerState<RouteDescriptionContent> {
  late int currentIndex;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CarouselSliderWidget(
            route: widget.route,
            items: widget.myItems,
            count: widget.myItems.length,

            ref: ref,
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Column(
              children: [
                RouteTitleNameWidget(text: widget.route.name),
                RouteMetaInfoWidget(
                  rating: widget.averageRating ?? 0.0,
                  reviewsCount: widget.commentsCount ?? 0,
                ),
                const SizedBox(height: 20),
                RouteCreatorInfoWidget(
                  creator: widget.creator,
                  averageUserRoutesRating: double.parse(
                    (widget.averageUserRoutesRating ?? 0.0).toStringAsFixed(1),
                  ),
                  userRoutesCount: widget.userRoutesCount ?? 0,
                  route: widget.route,

                  creatorName: widget.creator.name ?? 'Аноним',
                ),

                const SizedBox(height: 20),
                RouteDescriptionWidget(route: widget.route),
                const SizedBox(height: 20),

                const SizedBox(height: 20),
                RoutePointsWidget(widget.route.id),
                const SizedBox(height: 20),
                TipsWidget(widget.route.id),
                const SizedBox(height: 20),
                ReviewsSectionWidget(
                  route: widget.route,
                  commentList: widget.commentsList,
                  onPressed: widget.onReviewPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
