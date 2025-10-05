import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/data/repositories/route_repository_impl.dart';
import 'package:travelcompanion/core/domain/repositories/route_repository.dart';

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepositoryImpl();
});
