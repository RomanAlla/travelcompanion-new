import 'dart:io';
import 'package:travelcompanion/core/domain/entities/route_model.dart';

abstract class RouteRepository {
  Future<RouteModel> createRoute({
    required String creatorId,
    required String name,
    required String description,
    List<String>? photoUrls,
    required int travelDuration,
  });

  Future<List<RouteModel>> getRoutes();

  Future<List<RouteModel>> getUserRoutes({required String creatorId});

  Future<RouteModel> getRoutesById({required String id});

  Future<int?> getUserRoutesCount({required String creatorId});

  Future<double?> getAverageUserRoutesRating({required String userId});

  Future<void> updateRoute({
    required String id,
    String? name,
    String? description,
    List<String>? photoUrls,
    int? travelDuration,
  });

  Future<void> deleteRoute(String routeId);

  Future<List<String>?> updateRoutePhotos({
    required List<File> files,
    required String id,
  });

  Future<List<RouteModel>> searchRoutes({
    String? query,
    required String userId,
  });

  Future<double?> getAverageRouteRating(String id);
}
