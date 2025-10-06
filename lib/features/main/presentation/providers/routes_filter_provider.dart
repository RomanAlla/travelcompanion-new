import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_details_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_repository_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/routes_list_provider.dart';

final routeListProvider = FutureProvider<List<RouteModel>>((ref) async {
  return await ref.read(routeRepositoryProvider).getRoutes();
});

final routesFilterProvider = StateProvider((ref) => 'Все');

final filteredRoutesProvider = Provider<AsyncValue<List<RouteModel>>>((ref) {
  final asyncRoutes = ref.watch(routeListProvider);
  return asyncRoutes.whenData((routes) {
    final filter = ref.watch(routesFilterProvider);

    switch (filter) {
      case 'Созданные':
        final user = ref.watch(authProvider).user;
        return routes.where((route) => route.creatorId == user?.id).toList();
      default:
        return routes;
    }
  });
});
