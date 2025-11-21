import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/core/presentation/widgets/app_bar.dart';
import 'package:travelcompanion/core/presentation/widgets/route_card_widget.dart';
import 'package:travelcompanion/features/moderation/presentation/providers/admin_routes_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_repository_provider.dart';

class AdminRoutesScreen extends ConsumerWidget {
  const AdminRoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(adminRoutesProvider);
    final repo = ref.watch(routeRepositoryProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBarWidget(title: 'Все маршруты'),
      ),
      body: routesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Произошла ошибка... Попробуйте позже')),
        data: (routes) {
          if (routes.isEmpty) {
            return const Center(child: Text('Пусто'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: routes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final route = routes[index];
              return Stack(
                children: [
                  RouteCardWidget(route: route),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      onPressed: () async {
                        await repo.deleteRoute(route.id);
                        ref.invalidate(adminRoutesProvider);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.white,
                            content: Center(
                              child: Text(
                                'Маршрут удален',
                                style: AppTheme.bodyMediumBold.copyWith(
                                  color: AppTheme.primaryLightColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      tooltip: 'Удалить',
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
