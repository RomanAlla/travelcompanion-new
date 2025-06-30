import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/router/router.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';
import 'package:travelcompanion/features/routes/presentation/providers/route_repository_provider.dart';
import 'package:travelcompanion/features/routes/presentation/providers/routes_list_provider.dart';
import 'package:travelcompanion/features/search/presentation/widgets/route_card_widget.dart';

@RoutePage()
class MainRoutesScreen extends ConsumerStatefulWidget {
  const MainRoutesScreen({super.key});

  @override
  ConsumerState<MainRoutesScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<MainRoutesScreen> {
  String _selectedCategory = 'Все';
  final List<String> categoryList = [
    'Все',
    'Тропики',
    'Острова',
    'Пещеры',
    'Популярное',
    'Особые',
  ];

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
    final routes = ref.watch(routesListProvider);
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
                      SliverToBoxAdapter(
                        child: Container(
                          color: Colors.white,
                          child: Stack(
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Добро пожаловать!',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Откройте для себя новые маршруты',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.blue[50],
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.blue[700],
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Поиск направлений',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Популярные направления',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 80,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    _buildPopularDestination(
                                      'Тропики',
                                      Icons.beach_access,
                                      Colors.blue[50]!,
                                      Colors.grey[600]!,
                                    ),
                                    _buildPopularDestination(
                                      'Острова',
                                      Icons.rocket,
                                      Colors.blue[50]!,
                                      Colors.grey[600]!,
                                    ),
                                    _buildPopularDestination(
                                      'Пещеры',
                                      Icons.dangerous,
                                      Colors.blue[50]!,
                                      Colors.grey[600]!,
                                    ),
                                    _buildPopularDestination(
                                      'Особые',
                                      Icons.nature,
                                      Colors.blue[50]!,
                                      Colors.grey[600]!,
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Смотреть все',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categoryList.length,
                            itemBuilder: (context, index) {
                              final category = categoryList[index];
                              final isSelected = category == _selectedCategory;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(category),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: Colors.blue[50],
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.blue[700]
                                        : Colors.grey[500],
                                    fontWeight: isSelected
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: routes.when(
                          data: (routesList) {
                            var filteredList = routesList.where((route) {
                              if (_selectedCategory == 'Все') {
                                return true;
                              }
                              return route.routeType == _selectedCategory;
                            }).toList();

                            if (filteredList.isEmpty) {
                              return SliverFillRemaining(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.explore_off,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Маршруты не найдены',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600],
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
                                final route = filteredList[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: RouteCardWidget(
                                    route: route,
                                    onTap: () => _toDescriptionScreen(route),
                                  ),
                                );
                              }, childCount: filteredList.length),
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
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          loading: () => const SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
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
                    color: Colors.blue.withOpacity(0.9),
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
                      onTap: () => context.router.push(MapWatchModeRoute()),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 24, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Карта',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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

  Widget _buildPopularDestination(
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      width: 100,
      height: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
