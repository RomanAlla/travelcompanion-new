import 'package:flutter/material.dart';
import 'package:travelcompanion/core/data/cache/preloaded_cached_image_provider.dart';
import 'package:travelcompanion/core/domain/utils/string_utils.dart';
import 'package:travelcompanion/core/domain/entities/user_model.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';

class RouteCreatorInfoWidget extends StatelessWidget {
  final String creatorName;
  final RouteModel route;
  final double averageUserRoutesRating;
  final int userRoutesCount;
  final UserModel creator;
  const RouteCreatorInfoWidget({
    super.key,
    required this.creatorName,
    required this.route,
    required this.creator,
    required this.averageUserRoutesRating,
    required this.userRoutesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
        child: Row(
          children: [
          // Аватар
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryLightColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey[100],
              backgroundImage: creator.avatarUrl != null
                  ? InstantAppCachedImage.getImageProvider(creator.avatarUrl!)
                  : null,
              child: creator.avatarUrl == null
                  ? Icon(
                      Icons.person_rounded,
                      color: AppTheme.primaryLightColor,
                      size: 32,
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
                  creatorName,
                        style: AppTheme.titleSmallBold.copyWith(
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLightColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Автор маршрута',
                    style: AppTheme.bodyMini.copyWith(
                      color: AppTheme.primaryLightColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.orange.shade700,
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                    Text(
                            averageUserRoutesRating.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                    ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.route_rounded,
                            color: Colors.grey[700],
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                    Text(
                      StringUtils.pluralizeRoute(userRoutesCount),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ],
      ),
    );
  }
}
