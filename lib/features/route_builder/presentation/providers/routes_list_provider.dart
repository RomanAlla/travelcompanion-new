import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_repository_provider.dart';

final routesListProvider = FutureProvider.autoDispose<List<RouteModel>>((
  ref,
) async {
  final repo = ref.watch(routeRepositoryProvider);
  return await repo.getRoutes();
});

final userRoutesListProvider = FutureProvider.autoDispose<List<RouteModel>>((
  ref,
) async {
  final repo = ref.watch(routeRepositoryProvider);
  final userId = ref.watch(authProvider).user!.id;
  return await repo.getUserRoutes(creatorId: userId);
});
