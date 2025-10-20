import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/data/cache/preloaded_cached_image_provider.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';

import 'package:travelcompanion/core/presentation/widgets/delete_button.dart';
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

class _RouteCardContent extends ConsumerWidget {
  final RouteListState data;
  final VoidCallback? onTap;
  final bool canDelete;

  const _RouteCardContent({
    required this.data,
    this.onTap,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            _buildImage(),

            // Контент
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок и рейтинг
                  _buildHeader(),
                  const SizedBox(height: 8),

                  // Описание
                  _buildDescription(),
                  const SizedBox(height: 16),

                  // Автор и кнопки
                  _buildFooter(ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final hasImage = data.route.photoUrls.isNotEmpty;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        height: 300,
        color: Colors.grey[100],
        child: hasImage
            ? InstantAppCachedImage(
                imageUrl: data.route.photoUrls.first,
                height: 300,
                fit: BoxFit.cover,
                width: double.infinity,
              )
            : SizedBox(
                height: 300,
                width: double.infinity,
                child: Icon(Icons.landscape, size: 64, color: Colors.grey[400]),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            data.route.name,
            style: AppTheme.bodyMediumBold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _buildRating(),
      ],
    );
  }

  Widget _buildRating() {
    return data.rating != 0.0
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  data.rating?.toStringAsFixed(1) ?? '',
                  style: AppTheme.bodySmallBold,
                ),
              ],
            ),
          )
        : SizedBox();
  }

  Widget _buildDescription() {
    return Text(
      data.route.description ?? 'Нет описания',
      style: AppTheme.bodyMedium,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(WidgetRef ref) {
    return Row(
      children: [
        // Автор
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blue[100],
          backgroundImage: data.route.creator!.avatarUrl != null
              ? InstantAppCachedImage.getImageProvider(
                  data.route.creator!.avatarUrl!,
                )
              : null,
          child: data.route.creator!.avatarUrl == null
              ? const Icon(Icons.person, size: 16, color: Colors.blue)
              : null,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.route.creator?.name ?? 'Автор',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              '${data.userRoutesCount} маршрутов',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),

        const Spacer(),

        if (canDelete)
          DeleteButtonWidget(onPressed: () => _onDelete(ref, data.route.id)),

        _buildActionButton(Icons.favorite_border, () {}),
        const SizedBox(width: 8),
        _buildActionButton(Icons.share, () {}),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: Colors.grey[100],
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  void _onDelete(WidgetRef ref, routeId) {
    final user = ref.watch(authProvider).user;
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(height: 200, color: Colors.grey[200]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(height: 20, color: Colors.grey[300]),
                    ),
                    Container(width: 60, height: 20, color: Colors.grey[300]),
                  ],
                ),
                const SizedBox(height: 8),
                Container(height: 40, color: Colors.grey[200]),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CircleAvatar(backgroundColor: Colors.grey),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 12,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 10,
                          color: Colors.grey[200],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(width: 100, height: 32, color: Colors.grey[200]),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Container(
            height: 200,
            color: Colors.red[50],
            child: const Icon(Icons.error_outline, size: 48, color: Colors.red),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Ошибка загрузки',
                  style: TextStyle(color: Colors.red[700]),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () {
                    // Перезагрузить
                  },
                  child: const Text('Попробовать снова'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
