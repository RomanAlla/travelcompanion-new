import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/routes/data/models/interesting_route_points_model.dart';
import 'package:travelcompanion/features/routes/data/repository/interesting_route_points_repository.dart';

final interestingRoutePointsListProvider =
    FutureProvider<List<InterestingRoutePointsModel>>((ref) async {
      final repo = ref.watch(interestingRoutePointsRepositoryProvider);
      return await repo.getPoints();
    });

final interestingRoutePointsRepositoryProvider = Provider((ref) {
  return InterestingRoutePointsRepository();
});
