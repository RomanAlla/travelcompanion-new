import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/routes/data/repository/route_point_repository.dart';

final routePointRepositoryProvider = Provider<RoutePointRepository>((ref) {
  return RoutePointRepository();
});
