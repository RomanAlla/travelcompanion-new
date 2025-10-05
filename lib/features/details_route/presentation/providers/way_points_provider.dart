import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/entities/route_point_model.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_point_repository_provider.dart';

final wayPointsListProvider =
    FutureProvider.family<List<RoutePointsModel>, String>((ref, routeId) {
      return ref
          .watch(routePointRepositoryProvider)
          .getWayPoints(routeId: routeId);
    });
