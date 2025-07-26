import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/router/router.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';
import 'package:travelcompanion/features/routes/presentation/providers/route_repository_provider.dart';
import 'package:travelcompanion/features/search/presentation/providers/search_routes_provider.dart';
import 'package:travelcompanion/core/widgets/route_card_widget.dart';

@RoutePage()
class SearchMainScreen extends ConsumerStatefulWidget {
  const SearchMainScreen({super.key});

  @override
  ConsumerState<SearchMainScreen> createState() => _SearchMainScreen2State();
}

class _SearchMainScreen2State extends ConsumerState<SearchMainScreen> {
  int selectedCategory = 0;
  String pickedCategory = 'Тропики';
  final _searchController = TextEditingController();
  String? _searchQuery = '';

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.beach_access, 'label': 'Тропики'},
    {'icon': Icons.rocket, 'label': 'Острова'},
    {'icon': Icons.dangerous, 'label': 'Пещеры'},
    {'icon': Icons.local_fire_department, 'label': 'Популярные'},
    {'icon': Icons.nature, 'label': 'Особые'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при переходе: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final routesList = ref.watch(searchRoutesProvider(_searchQuery));
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Поиск маршрутов',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Поиск направлений',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        suffixIcon: _searchQuery!.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = index == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(
                        category['icon'] as IconData,
                        size: 18,
                        color: isSelected ? Colors.blue[700] : Colors.grey[600],
                      ),
                      label: Text(
                        category['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected
                              ? Colors.blue[700]
                              : Colors.grey[600],
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = index;
                          pickedCategory = category['label'] as String;
                        });
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: Colors.blue[50],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: routesList.when(
                data: (routesList) {
                  var filteredList = routesList.where((route) {
                    return route.routeType == pickedCategory;
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
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
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final route = filteredList[index];
                      return RouteCardWidget(
                        route: route,
                        onTap: () => _toDescriptionScreen(route),
                      );
                    },
                  );
                },
                error: (error, _) => Center(
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
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
