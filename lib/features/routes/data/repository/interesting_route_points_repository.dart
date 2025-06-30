import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/features/routes/data/models/interesting_route_points_model.dart';

class InterestingRoutePointsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<InterestingRoutePointsModel> createPoint({
    required String routeId,
    required String name,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw 'Пользователь не авторизован';
      }

      final data = {
        'name': name,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'route_id': routeId,
      };

      final response = await _supabase
          .from('interesting_route_points')
          .insert(data)
          .select()
          .single();

      return InterestingRoutePointsModel.fromJson(response);
    } catch (e) {
      print(e.toString());
      throw 'Ошибка создания интересной точки';
    }
  }

  Future<List<InterestingRoutePointsModel>> getInterestingPointsByRouteId(
    String routeId,
  ) async {
    try {
      final response = await _supabase
          .from('interesting_route_points')
          .select()
          .eq('route_id', routeId);

      final pointsList = response
          .map((response) => InterestingRoutePointsModel.fromJson(response))
          .toList();

      return pointsList;
    } catch (e) {
      print(e.toString());
      throw 'Ошибка получения интересных точек по ID маршрута';
    }
  }

  Future<List<InterestingRoutePointsModel>> getPoints() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw 'Пользователь не авторизован';
      }

      final response = await _supabase
          .from('interesting_route_points')
          .select()
          .eq('user_id', user.id);

      final pointsList = response
          .map((response) => InterestingRoutePointsModel.fromJson(response))
          .toList();

      return pointsList;
    } catch (e) {
      print(e.toString());
      throw 'Ошибка получения интересных точек';
    }
  }
}
