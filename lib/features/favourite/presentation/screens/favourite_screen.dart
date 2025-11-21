import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/exceptions/error_handler.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/features/details_route/presentation/screens/route_description_screen.dart';
import 'package:travelcompanion/features/favourite/presentation/widgets/empty_state_widget.dart';
import 'package:travelcompanion/features/favourite/presentation/widgets/error_state_widget.dart';
import 'package:travelcompanion/features/favourite/presentation/widgets/loading_state_widget.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/favourite_repository_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_repository_provider.dart';
import 'package:travelcompanion/core/presentation/widgets/route_card_widget.dart';

@RoutePage()
class FavouriteScreen extends ConsumerStatefulWidget {
  const FavouriteScreen({super.key});

  @override
  ConsumerState<FavouriteScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<FavouriteScreen> {
  Future<void> _toDescriptionScreen(RouteModel route) async {
    try {
      final rep = ref.read(routeRepositoryProvider);
      final completeRoute = await rep.getRoutesById(id: route.id);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RouteDescriptionScreen(
              route: completeRoute,
              routeId: completeRoute.id,
            ),
          ),
        );
      }
    } catch (e) {
      ErrorHandler.getErrorMessage(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favouriteList = ref.watch(favouriteListProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: CustomScrollView(
        slivers: [
          // Hero AppBar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(color: AppTheme.accentColor),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Избранное',
                              style: AppTheme.titleLarge.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: favouriteList.when(
                data: (favouriteList) {
                  if (favouriteList.isEmpty) {
                    return EmptyStateWidget();
                  }
                  return Column(
                    children: [
                      // Статистика
                      Container(
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
                            Expanded(
                              child: _buildStatItem(
                                icon: Icons.favorite_rounded,
                                value: '${favouriteList.length}',
                                label: 'Маршрутов',
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                icon: Icons.star_rounded,
                                value:
                                    favouriteList.isNotEmpty ? '4.5' : '0.0',
                                label: 'Средний рейтинг',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Список маршрутов
                      ...favouriteList.map(
                        (route) => RouteCardWidget(
                          canDelete: true,
                          route: route,
                          onTap: () => _toDescriptionScreen(route),
                        ),
                      ),
                    ],
                  );
                },
                error: (error, _) => ErrorStateWidget(error: error),
                loading: () => LoadingStateWidget(),
              ),
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
      children: [
        Icon(icon, color: AppTheme.accentColor, size: 22),
        const SizedBox(height: 6),
        Text(value, style: AppTheme.titleSmallBold.copyWith(fontSize: 18)),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTheme.bodyMini.copyWith(
            color: Colors.grey[600],
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
