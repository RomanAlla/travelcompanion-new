import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/routes/data/models/interesting_route_points_model.dart';
import 'package:travelcompanion/features/routes/presentation/providers/interesting_route_points_repository_provider.dart';

final interestingRoutePointsByRouteIdProvider =
    FutureProvider.family<List<InterestingRoutePointsModel>, String>(
        (ref, routeId) async {
  final repo = ref.watch(interestingRoutePointsModelProvider);
  return await repo.getInterestingPointsByRouteId(routeId);
});
