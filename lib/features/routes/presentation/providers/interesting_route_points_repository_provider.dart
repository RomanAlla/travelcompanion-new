import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/routes/data/models/interesting_route_points_model.dart';
import 'package:travelcompanion/features/routes/data/repository/interesting_route_points_repository.dart';

final interestingRoutePointsListProvider =
    FutureProvider<List<InterestingRoutePointsModel>>((
  ref,
) async {
  final repo = ref.watch(interestingRoutePointsModelProvider);
  return await repo.getPoints();
});

final interestingRoutePointsModelProvider = Provider((ref) {
  return InterestingRoutePointsRepository();
});
