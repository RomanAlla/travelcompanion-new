import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/data/cache/preloaded_cached_image_provider.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';

import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/route_list_state.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/favourite_repository_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/routes_list_provider.dart';

class RouteCardWidget extends ConsumerWidget {
  final RouteModel route;
  final VoidCallback? onTap;
  final bool canDelete;

  const RouteCardWidget({
    super.key,
    required this.route,
    this.onTap,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeData = ref.watch(routeCardProvider(route.id));

    return routeData.when(
      loading: () => const _RouteCardSkeleton(),
      error: (error, stack) => _RouteCardError(routeId: route.id),
      data: (data) =>
          _RouteCardContent(data: data, onTap: onTap, canDelete: canDelete),
    );
  }
}

class _RouteCardContent extends ConsumerStatefulWidget {
  final RouteListState data;
  final VoidCallback? onTap;
  final bool canDelete;

  const _RouteCardContent({
    required this.data,
    this.onTap,
    required this.canDelete,
  });

  @override
  ConsumerState<_RouteCardContent> createState() => _RouteCardContentState();
}

class _RouteCardContentState extends ConsumerState<_RouteCardContent>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.99 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
      child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            borderRadius: BorderRadius.circular(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  _buildImage(),
                  _buildContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final hasImage = widget.data.route.photoUrls.isNotEmpty;
    final duration = widget.data.route.travelDuration ?? 0;
    final hours = duration ~/ 60;
    final minutes = duration % 60;

    return Stack(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
        color: Colors.grey[100],
          ),
        child: hasImage
            ? InstantAppCachedImage(
                  imageUrl: widget.data.route.photoUrls.first,
                  height: 220,
                fit: BoxFit.cover,
                width: double.infinity,
              )
              : Center(
                  child: Icon(
                    Icons.landscape,
                    size: 60,
                    color: Colors.grey[400],
              ),
      ),
        ),
        // Легкий оверлей
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        ),
        // Бейджи
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Row(
      children: [
              if (widget.data.rating != null && widget.data.rating! > 0)
                _buildImageBadge(
                  icon: Icons.star_rounded,
                  text: widget.data.rating!.toStringAsFixed(1),
                  color: Colors.orange.shade600,
                ),
              const Spacer(),
              if (duration > 0)
                _buildImageBadge(
                  icon: Icons.access_time_rounded,
                  text: hours > 0 ? '$hoursч $minutesм' : '$minutesм',
                  color: Colors.white.withValues(alpha: 0.85),
                  textColor: Colors.black87,
                ),
            ],
          ),
        ),
        // Индикатор приватности
        if (widget.data.route.name.contains('Приватный'))
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade600,
                borderRadius: BorderRadius.circular(12),
          ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Приватный',
                    style: AppTheme.bodyMini.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageBadge({
    required IconData icon,
    required String text,
    required Color color,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor ?? Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTheme.bodyMini.copyWith(
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Text(
            widget.data.route.name,
            style: AppTheme.titleSmallBold.copyWith(
              fontSize: 18,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Описание
                Text(
            widget.data.route.description ?? 'Нет описания',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[700],
              height: 1.4,
              fontSize: 14,
            ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Футер
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // Автор
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[100],
            backgroundImage: widget.data.route.creator!.avatarUrl != null
              ? InstantAppCachedImage.getImageProvider(
                    widget.data.route.creator!.avatarUrl!,
                )
              : null,
            child: widget.data.route.creator!.avatarUrl == null
                ? Icon(
                    Icons.person,
                    size: 18,
                    color: AppTheme.primaryLightColor,
                  )
              : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                widget.data.route.creator?.name ?? 'Автор',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
            ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.route,
                    size: 11,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
            Text(
                    '${widget.data.userRoutesCount} маршрутов',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
            ),
          ],
        ),
            ],
          ),
        ),
        // Кнопки действий
        if (widget.canDelete)
          _buildActionButton(
            icon: Icons.delete_outline,
            onTap: () => _onDelete(widget.data.route.id),
            color: Colors.red.shade400,
          ),
        const SizedBox(width: 6),
        _buildActionButton(
          icon: Icons.favorite_border,
          onTap: () {},
          color: AppTheme.primaryLightColor,
        ),
        const SizedBox(width: 6),
        _buildActionButton(
          icon: Icons.share,
          onTap: () {},
          color: Colors.grey[600]!,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
        padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }

  void _onDelete(String routeId) {
    final user = ref.read(authProvider).user;
    ref
        .read(favouriteRepository)
        .removeFromFavourites(userId: user!.id, routeId: routeId);
    ref.invalidate(favouriteListProvider);
  }
}

class _RouteCardSkeleton extends StatelessWidget {
  const _RouteCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                    ),
                const SizedBox(height: 10),
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 90,
                          height: 12,
                          decoration: BoxDecoration(
                          color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 70,
                          height: 10,
                          decoration: BoxDecoration(
                          color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
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

class _RouteCardError extends StatelessWidget {
  final String routeId;

  const _RouteCardError({required this.routeId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
            color: Colors.red[50],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: const Icon(Icons.error_outline, size: 40, color: Colors.red),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Ошибка загрузки',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLightColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                    // Перезагрузить
                  },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: const Text(
                          'Попробовать снова',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
