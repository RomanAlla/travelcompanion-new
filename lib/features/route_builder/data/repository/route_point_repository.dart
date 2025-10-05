import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/core/domain/exceptions/app_exception.dart';
import 'package:travelcompanion/core/domain/entities/route_point_model.dart';
import 'package:travelcompanion/core/domain/repositories/route_point_repository.dart';

class RoutePointRepositoryImpl implements RoutePointRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<RoutePointsModel> createRoutePoint({
    required String routeId,
    required double latitude,
    required double longitude,
    required int order,
    required String type,
  }) async {
    try {
      final data = {
        'route_id': routeId,
        'latitude': latitude,
        'longitude': longitude,
        'order': order,
        'type': type,
      };
      final response = await _supabase
          .from('route_points')
          .insert(data)
          .select()
          .single();

      return RoutePointsModel.fromJson(response);
    } catch (e) {
      throw AppException('Ошибка в создании route point: $e');
    }
  }

  @override
  Future<List<RoutePointsModel>> getPoints({required String routeId}) async {
    try {
      final response = await _supabase
          .from('route_points')
          .select()
          .eq('route_id', routeId)
          .order('order', ascending: true);
      final points = response
          .map((response) => RoutePointsModel.fromJson(response))
          .toList();
      return points;
    } catch (e) {
      throw AppException('Ошибка в получении route point: $e');
    }
  }

  @override
  Future<List<RoutePointsModel>> getAllPoints() async {
    try {
      final response = await _supabase.from('route_points').select();

      final points = response
          .map((response) => RoutePointsModel.fromJson(response))
          .toList();
      return points;
    } catch (e) {
      throw AppException('Ошибка в получении all route point: $e');
    }
  }

  @override
  Future<RoutePointsModel> updateRoutePoint({
    required String id,
    required String routeId,
    required String name,
    required double latitude,
    required double longitude,
    String? description,
    String? photoUrl,
    int? order,
  }) async {
    final data = {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'photoUrl': photoUrl,
      'order': order,
    };
    try {
      final response = await _supabase
          .from('route_points')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return RoutePointsModel.fromJson(response);
    } catch (e) {
      throw AppException('Ошибка в обновлении точки: $e');
    }
  }

  @override
  Future<void> deleteRoutePoint({required String id}) async {
    try {
      await _supabase.from('route_points').delete().eq('id', id);
    } catch (e) {
      throw AppException('Ошибка в удалении route point: $e');
    }
  }

  @override
  Future<List<RoutePointsModel>> getWayPoints({required String routeId}) async {
    try {
      final response = await _supabase
          .from('route_points')
          .select()
          .eq('route_id', routeId)
          .eq('type', 'waypoint');
      final wayPoints = response.map(
        (response) => RoutePointsModel.fromJson(response),
      );
      return wayPoints.toList();
    } catch (e) {
      throw AppException('Ошибка в получении way points: $e');
    }
  }

  @override
  Future<RoutePointsModel> getRoutePointById({required String id}) async {
    try {
      final response = await _supabase
          .from('route_points')
          .select()
          .eq('id', id)
          .single();
      return RoutePointsModel.fromJson(response);
    } catch (e) {
      throw AppException('Ошибка в получении route point по id: $e');
    }
  }
}
