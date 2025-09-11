import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/auth/data/models/user_model.dart';
import 'package:travelcompanion/features/details_route/data/models/comment_model.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/carousel_slider_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/reviews_section_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/route_creator_info_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/route_description_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/route_meta_info_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/route_points_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/route_title_name_widget.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/tips_widget.dart';
import 'package:travelcompanion/features/route_builder/data/models/route_model.dart'
    show RouteModel;

class RouteDescriptionContent extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CarouselSliderWidget(
            route: route,
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
                RouteTitleNameWidget(text: route.name),
                RouteMetaInfoWidget(
                  rating: averageRating ?? 0.0,
                  reviewsCount: commentsCount ?? 0,
                ),
                const SizedBox(height: 20),
                RouteCreatorInfoWidget(
                  creator: creator,
                  averageUserRoutesRating: double.parse(
                    (averageUserRoutesRating ?? 0.0).toStringAsFixed(1),
                  ),
                  userRoutesCount: userRoutesCount ?? 0,
                  route: route,

                  creatorName: creator.name ?? 'Аноним',
                ),

                const SizedBox(height: 20),
                RouteDescriptionWidget(route: route),
                const SizedBox(height: 20),

                const SizedBox(height: 20),
                RoutePointsWidget(route.id),
                const SizedBox(height: 20),
                TipsWidget(route.id),
                const SizedBox(height: 20),
                ReviewsSectionWidget(
                  route: route,
                  commentList: commentsList,
                  onPressed: onReviewPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
