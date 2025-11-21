import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_repository_provider.dart';

final adminRoutesProvider = FutureProvider<List<RouteModel>>((ref) async {
  final repo = ref.watch(routeRepositoryProvider);
  return await repo.getRoutes();
});


