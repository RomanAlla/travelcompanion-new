import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/features/favourite/data/models/favourite_model.dart';
import 'package:travelcompanion/features/route_builder/data/models/route_model.dart';
import 'package:travelcompanion/core/error/app_exception.dart';

class FavouriteRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<FavouriteModel> addToFavourite({
    required String userId,
    required String routeId,
  }) async {
    try {
      final data = {'user_id': userId, 'route_id': routeId};
      final response = await _supabase
          .from('favourite_routes')
          .insert(data)
          .select()
          .single();
      return FavouriteModel.fromJson(response);
    } catch (e) {
      throw AppException('Ошибка добавления в избранное: $e');
    }
  }

  Future<void> removeFromFavourites({
    required String userId,
    required String routeId,
  }) async {
    try {
      await _supabase.from('favourite_routes').delete().match({
        'user_id': userId,
        'route_id': routeId,
      });
    } catch (e) {
      throw AppException('Ошибка удаления из избранного: $e');
    }
  }

  Future<List<RouteModel>> getFavouriteRoutes({required String userId}) async {
    try {
      final response = await _supabase
          .from('favourite_routes')
          .select('''route:route_id(*, creator:creator_id(*))''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return response.map((item) {
        final route = item['route'] as Map<String, dynamic>;

        return RouteModel.fromJson(route);
      }).toList();
    } catch (e) {
      throw AppException('Ошибка получения избранных маршрутов: $e');
    }
  }

  Future<bool> isRouteFavourite({
    required String routeId,
    required String userId,
  }) async {
    try {
      final response = await _supabase.from('favourite_routes').select().match({
        'user_id': userId,
        'route_id': routeId,
      }).maybeSingle();
      return response != null;
    } catch (e) {
      throw AppException('Ошибка проверки избранного: $e');
    }
  }
}
