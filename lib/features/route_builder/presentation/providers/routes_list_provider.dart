import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/route_list_state.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_repository_provider.dart';

final routeCardProvider = FutureProvider.family<RouteListState, String>((
  ref,
  routeId,
) async {
  final routeRepo = ref.watch(routeRepositoryProvider);

  final route = await routeRepo.getRoutesById(id: routeId);
  final rating = await routeRepo.getAverageRouteRating(routeId);
  final userRoutesCount = await routeRepo.getUserRoutesCount(
    creatorId: route.creator!.id,
  );

  return RouteListState(
    route: route,
    rating: rating,
    userRoutesCount: userRoutesCount,
  );
});

final userRoutesListProvider = FutureProvider.autoDispose<List<RouteModel>>((
  ref,
) async {
  final repo = ref.watch(routeRepositoryProvider);
  final userId = ref.watch(authProvider).user!.id;
  return await repo.getUserRoutes(creatorId: userId);
});
