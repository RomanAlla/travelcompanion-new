import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/entities/user_model.dart';
import 'package:travelcompanion/core/domain/entities/comment_model.dart';
import 'package:travelcompanion/core/presentation/router/router.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
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
import 'package:travelcompanion/features/map/domain/enums/map_mode.dart';
import 'package:travelcompanion/features/map/presentation/providers/map_state_notifier_provider.dart';

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

  void startRoute() async {
    context.router.push(MapRoute(mode: MapMode.viewAll));
    ref.read(mapStateNotifierProvider.notifier).setPickedRoute(widget.route);
  }

  Widget _buildPrivacyIndicator() {
    final bool isPrivate = widget.route.name.toLowerCase().contains(
      'Приватный',
    );

    if (!isPrivate) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, size: 12, color: Colors.orange.shade700),
          const SizedBox(width: 4),
          Text(
            'Приватный маршрут',
            style: AppTheme.bodyMini.copyWith(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    final duration = widget.route.travelDuration ?? 0;
    final hours = duration ~/ 60;
    final minutes = duration % 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryLightColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryLightColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.access_time_rounded,
              value: hours > 0 ? '$hoursч $minutesм' : '$minutesм',
              label: 'Время',
            ),
          ),
          Container(
            width: 1,
            height: 35,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.star_rounded,
              value: (widget.averageRating ?? 0.0).toStringAsFixed(1),
              label: 'Рейтинг',
            ),
          ),
          Container(
            width: 1,
            height: 35,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.comment_rounded,
              value: '${widget.commentsCount ?? 0}',
              label: 'Отзывов',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.primaryLightColor, size: 20),
        const SizedBox(height: 6),
        Text(value, style: AppTheme.titleSmallBold.copyWith(fontSize: 16)),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTheme.bodyMini.copyWith(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: CarouselSliderWidget(
              route: widget.route,
              items: widget.myItems,
              count: widget.myItems.length,
              ref: ref,
            ),
          ),
        ),
        // Контент
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Заголовок и мета-информация
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RouteTitleNameWidget(text: widget.route.name),
                              const SizedBox(height: 6),
                              RouteMetaInfoWidget(
                                rating: widget.averageRating ?? 0.0,
                                reviewsCount: widget.commentsCount ?? 0,
                              ),
                              _buildPrivacyIndicator(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Кнопка "В путь!"
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.successColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.successColor.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: startRoute,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.directions_walk_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'В путь!',
                                      style: AppTheme.bodySmallBold.copyWith(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Статистика
              _buildStatsSection(),
              // Информация о создателе
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RouteCreatorInfoWidget(
                  creator: widget.creator,
                  averageUserRoutesRating: double.parse(
                    (widget.averageUserRoutesRating ?? 0.0).toStringAsFixed(1),
                  ),
                  userRoutesCount: widget.userRoutesCount ?? 0,
                  route: widget.route,
                  creatorName: widget.creator.name ?? 'Аноним',
                ),
              ),
              const SizedBox(height: 16),
              // Описание
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RouteDescriptionWidget(route: widget.route),
              ),
              const SizedBox(height: 16),
              // Точки маршрута
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoutePointsWidget(widget.route.id),
              ),
              const SizedBox(height: 16),
              // Советы
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TipsWidget(widget.route.id),
              ),
              const SizedBox(height: 16),
              // Отзывы
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ReviewsSectionWidget(
                  route: widget.route,
                  commentList: widget.commentsList,
                  onPressed: widget.onReviewPressed,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}
