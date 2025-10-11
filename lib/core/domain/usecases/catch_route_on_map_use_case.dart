import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/repositories/route_point_repository.dart';
import 'package:travelcompanion/features/map/presentation/providers/map_state_notifier_provider.dart';
import 'package:travelcompanion/features/route_builder/data/repository/route_point_repository.dart';

class CatchRouteOnMapUseCase {
  final RoutePointRepository _routePointRepository;
  CatchRouteOnMapUseCase(this._routePointRepository);
}
