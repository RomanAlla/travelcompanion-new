import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/features/routes/data/models/favourite_model.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';

class FavouriteRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<FavouriteModel> addToFavourite({
    required String userId,
    required String routeId,
  }) async {
    try {
      final data = {'user_id': userId, 'route_id': routeId};
      final response = await _supabase
          .from('favourites')
          .insert(data)
          .select()
          .single();
      return FavouriteModel.fromJson(response);
    } catch (e) {
      print(e.toString());
      throw 'Ошибка добавления в избранное';
    }
  }

  Future<void> removeFromFavourites({
    required String userId,
    required String routeId,
  }) async {
    try {
      await _supabase.from('favourites').delete().match({
        'user_id': userId,
        'route_id': routeId,
      });
    } catch (e) {
      print(e.toString());
      throw 'Ошибка удаления из избранного';
    }
  }

  Future<List<RouteModel>> getFavouriteRoutes({required String userId}) async {
    try {
      final response = await _supabase
          .from('favourites')
          .select('''route:route_id(*, creator:user_id(name, avatar_url))''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return response.map((item) {
        final route = item['route'] as Map<String, dynamic>;
        final creator = route['creator'] as Map<String, dynamic>;
        return RouteModel(
          id: route['id'] as String,
          photoUrls:
              (route['photo_urls'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
          creatorId: route['creator_id'] as String,
          name: route['name'] as String? ?? '',
          description: route['description'] as String? ?? '',
          latitude: route['latitude'] as double?,
          routeType: route['route_type'] as String? ?? '',
          longitude: route['longitude'] as double?,
          createdAt: DateTime.parse(route['created_at'] as String),
        );
      }).toList();
    } catch (e) {
      print(e.toString());
      throw 'Ошибка получения избранных маршрутов';
    }
  }

  Future<bool> isRouteFavourite({
    required String routeId,
    required String userId,
  }) async {
    try {
      final response = await _supabase.from('favourites').select().match({
        'user_id': userId,
        'route_id': routeId,
      }).maybeSingle();
      return response != null;
    } catch (e) {
      print(e.toString());
      throw 'Ошибка проверки избранного';
    }
  }
}
