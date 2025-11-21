import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/presentation/router/router.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/core/presentation/widgets/app_bar.dart';
import 'package:travelcompanion/core/presentation/widgets/choice_chip_widget.dart';
import 'package:travelcompanion/core/presentation/widgets/search_bar_widget.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/main/presentation/providers/routes_filter_provider.dart';
import 'package:travelcompanion/features/map/domain/enums/map_mode.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_repository_provider.dart';
import 'package:travelcompanion/core/presentation/widgets/route_card_widget.dart';

@RoutePage()
class MainRoutesScreen extends ConsumerStatefulWidget {
  const MainRoutesScreen({super.key});

  @override
  ConsumerState<MainRoutesScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<MainRoutesScreen> {
  final List<String> categoryList = ['Все', 'Сохраненные', 'Созданные'];

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTheme.titleSmallBold.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTheme.bodyMini.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void toSearchScreen() {
    context.router.push(const SearchMainRoute());
  }

  Future<void> _toDescriptionScreen(RouteModel route) async {
    try {
      final rep = ref.read(routeRepositoryProvider);
      final completeRoute = await rep.getRoutesById(id: route.id);
      if (mounted) {
        context.router.push(
          RouteDescriptionRoute(
            routeId: completeRoute.id,
            route: completeRoute,
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authProvider).user;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        flexibleSpace: AppBarWidget(title: 'Travel Companion'),
                      ),
                      SliverAppBar(
                        pinned: true,
                        backgroundColor: Colors.white,
                        elevation: 0,
                        toolbarHeight: 72,
                        flexibleSpace: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.05),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: toSearchScreen,
                            child: AbsorbPointer(child: SearchBarWidget()),
                          ),
                        ),
                      ),

                      // Компактная статистика и AI помощник
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            // AI помощник
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.secondaryColor,
                                    AppTheme.deepPurpleColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.secondaryColor.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    context.router.push(ChatRoute());
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.auto_awesome_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'AI Помощник',
                                                style: AppTheme.titleSmallBold
                                                    .copyWith(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Задайте вопрос о маршрутах',
                                                style: AppTheme.bodySmall
                                                    .copyWith(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.9,
                                                          ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Статистика
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLightColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryLightColor
                                        .withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      icon: Icons.route,
                                      value:
                                          '${ref.watch(filteredRoutesProvider).maybeWhen(data: (routes) => routes.length, orElse: () => 0)}',
                                      label: 'Маршрутов',
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  Expanded(
                                    child: _buildStatCard(
                                      icon: Icons.favorite,
                                      value:
                                          '${ref.watch(filteredRoutesProvider).maybeWhen(data: (routes) => routes.length, orElse: () => 0)}',
                                      label: 'Популярных',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Заголовок и кнопка создания
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Все маршруты',
                                style: AppTheme.titleSmallBold.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLightColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryLightColor
                                          .withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      context.router.push(CreateRouteRoute());
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.add_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Создать',
                                            style: AppTheme.bodySmallBold
                                                .copyWith(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: ChoiceChipBuilderWidget()),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: ref
                            .watch(filteredRoutesProvider)
                            .when(
                              data: (filteredRoutes) {
                                if (filteredRoutes.isEmpty) {
                                  return SliverFillRemaining(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.explore_off,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Маршруты не найдены',
                                            style: AppTheme.titleSmallBold
                                                .copyWith(
                                                  color: AppTheme.grey600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final route = filteredRoutes[index];
                                    return RouteCardWidget(
                                      route: route,
                                      onTap: () => _toDescriptionScreen(route),
                                    );
                                  }, childCount: filteredRoutes.length),
                                );
                              },
                              error: (error, _) => SliverFillRemaining(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 48,
                                        color: Colors.red[400],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Ошибка загрузки маршрутов',
                                        style: AppTheme.titleSmallBold.copyWith(
                                          color: AppTheme.grey600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              loading: () => SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) =>
                                      const _RouteCardSkeleton(),
                                  childCount: 3,
                                ),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLightColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryLightColor.withValues(
                          alpha: 0.25,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () =>
                          context.router.push(MapRoute(mode: MapMode.viewAll)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.map_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Карта',
                              style: AppTheme.bodySmallBold.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
            height: 200,
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
