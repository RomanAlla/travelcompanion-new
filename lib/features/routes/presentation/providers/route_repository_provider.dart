import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/routes/data/repository/route_repository.dart';

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepository();
});
