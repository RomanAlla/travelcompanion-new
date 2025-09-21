import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travelcompanion/core/router/router.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/comments_provider.dart';
import 'package:travelcompanion/features/route_builder/data/models/route_model.dart';

class ReviewsSectionWidget extends ConsumerWidget {
  final List? commentList;
  final void Function()? onPressed;
  final RouteModel route;
  const ReviewsSectionWidget({
    super.key,
    required this.commentList,
    required this.route,

    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentsProvider(route.id));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text('Отзывы', style: AppTheme.bodyLarge),
                ),
                TextButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.primaryLightColor,
                    size: 20,
                  ),
                  label: Text(
                    'Добавить отзыв',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryLightColor,
                    ),
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
          if (commentList == null)
            const Center(child: CircularProgressIndicator())
          else if (commentList!.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23.0),
              child: Text(
                'Нет отзывов. Будьте первым!',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.grey600),
              ),
            )
          else
            commentsAsync.when(
              data: (commentList) => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: commentList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final comment = commentList[index];
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.blue[100]!,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundImage:
                                    comment.creator?.avatarUrl != null
                                    ? NetworkImage(comment.creator!.avatarUrl!)
                                    : null,
                                backgroundColor: Colors.grey[200],
                                child: comment.creator?.avatarUrl == null
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                        size: 28,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          comment.creator?.name ??
                                              'Пользователь ${comment.creatorId.substring(0, 6)}...',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: List.generate(5, (i) {
                                          return Icon(
                                            i < comment.rating
                                                ? Icons.star_rounded
                                                : Icons.star_border_rounded,
                                            color: Colors.amber,
                                            size: 18,
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat(
                                      'dd MMM yyyy',
                                    ).format(comment.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (comment.text.trim().isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            comment.text,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ],
                        if (comment.images != null &&
                            comment.images!.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 90,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: comment.images!.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, imgIdx) {
                                final imageUrl = comment.images![imgIdx];
                                return GestureDetector(
                                  onTap: () => context.router.push(
                                    FullRouteCommentPhotosRoute(
                                      imageUrls: comment.images!,
                                      initialIndex: imgIdx,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imageUrl,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 90,
                                              height: 90,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.error,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              error: (e, _) => Text('Ошибка: $e'),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
