import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/repositories/route_point_repository.dart';
import 'package:travelcompanion/features/route_builder/data/repository/route_point_repository.dart';

final routePointRepositoryProvider = Provider<RoutePointRepository>((ref) {
  return RoutePointRepositoryImpl();
});
