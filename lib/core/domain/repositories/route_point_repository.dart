import 'package:travelcompanion/core/domain/entities/route_point_model.dart';

abstract class RoutePointRepository {
  Future<RoutePointsModel> createRoutePoint({
    required String routeId,
    required double latitude,
    required double longitude,
    required int order,
    required String type,
  });
  Future<List<RoutePointsModel>> getPoints({required String routeId});
  Future<List<RoutePointsModel>> getAllPoints();
  Future<RoutePointsModel> updateRoutePoint({
    required String id,
    required String routeId,
    required String name,
    required double latitude,
    required double longitude,
    String? description,
    String? photoUrl,
    int? order,
  });
  Future<void> deleteRoutePoint({required String id});
  Future<List<RoutePointsModel>> getWayPoints({required String routeId});
  Future<RoutePointsModel> getRoutePointById({required String id});
  Future<RoutePointsModel> getStartPoint({required String id});
}
