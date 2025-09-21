import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/router/router.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/core/widgets/app_bar.dart';
import 'package:travelcompanion/core/widgets/choice_chip_widget.dart';
import 'package:travelcompanion/core/widgets/search_bar_widget.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/main/presentation/providers/routes_filter_provider.dart';
import 'package:travelcompanion/features/map/domain/enums/map_mode.dart';
import 'package:travelcompanion/features/route_builder/data/models/route_model.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_repository_provider.dart';
import 'package:travelcompanion/core/widgets/route_card_widget.dart';

@RoutePage()
class MainRoutesScreen extends ConsumerStatefulWidget {
  const MainRoutesScreen({super.key});

  @override
  ConsumerState<MainRoutesScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<MainRoutesScreen> {
  final List<String> categoryList = ['Все', 'Сохраненные', 'Созданные'];

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
    } catch (e) {
      throw Exception(e.toString());
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
                                color: Colors.grey.withOpacity(0.05),
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

                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Все маршруты',
                                style: AppTheme.titleSmall.copyWith(
                                  color: AppTheme.grey600,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.router.push(CreateRouteRoute());
                                },
                                child: Text(
                                  'Создать маршрут',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.primaryLightColor,
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
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
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
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: RouteCardWidget(
                                        route: route,
                                        onTap: () =>
                                            _toDescriptionScreen(route),
                                      ),
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
                                        size: 64,
                                        color: Colors.red[400],
                                      ),
                                      const SizedBox(height: 16),
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
                              loading: () => const SliverFillRemaining(
                                child: Center(
                                  child: CircularProgressIndicator(),
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
                  height: 50,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLightColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () =>
                          context.router.push(MapRoute(mode: MapMode.viewAll)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 24, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Карта',
                            style: AppTheme.bodyMedium.copyWith(
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
          ],
        ),
      ),
    );
  }
}
