import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/features/routes/data/models/interesting_route_points_model.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';
import 'package:travelcompanion/core/service/supabase_service.dart';
import 'package:travelcompanion/core/error/app_exception.dart';

class RouteRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _bucketName = 'routes-photos';
  final SupabaseService _supabaseService = SupabaseService(
    Supabase.instance.client,
  );

  Future<RouteModel> createRoute({
    required String creatorId,
    required String name,
    String? description,

    List<InterestingRoutePointsModel>? interestingPoints,
    String? photoUrl,
    double? longitude,
    String? routeType,
    double? latitude,
  }) async {
    try {
      final data = {
        'creator_id': creatorId,
        'name': name,
        'description': description,
        'photo_urls': photoUrl,
        'route_type': routeType,
        'longitude': longitude,
        'latitude': latitude,
      };
      final response = await _supabase
          .from('routes')
          .insert(data)
          .select()
          .single();
      return RouteModel.fromJson(response);
    } catch (e) {
      throw AppException('Ошибка создания маршрута: $e');
    }
  }

  Future<List<RouteModel>> getRoutes() async {
    try {
      final response = await _supabase
          .from('routes')
          .select('''*, creator:creator_id(*)''')
          .order('created_at', ascending: false);
      final routes = response
          .map((response) => RouteModel.fromJson(response))
          .toList();

      return routes;
    } catch (e) {
      throw AppException('Ошибка получения маршрутов: $e');
    }
  }

  Future<List<RouteModel>> getUserRoutes({required String creatorId}) async {
    try {
      final response = await _supabase
          .from('routes')
          .select('''*, creator:creator_id(*)''')
          .eq('creator_id', creatorId)
          .order('created_at', ascending: false);

      final routes = response
          .map((response) => RouteModel.fromJson(response))
          .toList();

      return routes;
    } catch (e) {
      throw AppException('Ошибка получения маршрутов: $e');
    }
  }

  Future<RouteModel> getRoutesById({required String id}) async {
    try {
      final response = await _supabase
          .from('routes')
          .select('''*, creator:creator_id(*)''')
          .eq('id', id)
          .single();

      return RouteModel.fromJson(response);
    } catch (e) {
      throw AppException('Ошибка в получении пути: $e');
    }
  }

  Future<int?> getUserRoutesCount({required String creatorId}) async {
    try {
      final response = await _supabase
          .from('routes')
          .select('count')
          .eq('creator_id', creatorId);

      return response.first['count'] as int?;
    } catch (e) {
      throw AppException('Ошибка получения кол-ва путей юзера: $e');
    }
  }

  Future<double?> getAverageUserRoutesRating({required String userId}) async {
    try {
      final List<dynamic> userRoutesResponse = await _supabase
          .from('routes')
          .select('id')
          .eq('creator_id', userId);
      final List<String> routeIds = userRoutesResponse
          .map((item) => item['id'] as String)
          .toList();

      if (routeIds.isEmpty) {
        return null;
      }

      double? totalAvgRating;
      int ratedRoutesCount = 0;

      for (String routeId in routeIds) {
        final avgRatingForRoute = await _supabaseService.getAvgRating(routeId);
        if (avgRatingForRoute != null) {
          totalAvgRating = (totalAvgRating ?? 0) + avgRatingForRoute;
          ratedRoutesCount++;
        }
      }

      return ratedRoutesCount > 0 ? totalAvgRating! / ratedRoutesCount : null;
    } catch (e) {
      throw AppException('Ошибка получения avg рейтинга пользователя');
    }
  }

  Future<RouteModel> updateRoute({
    required String id,
    required String name,
    required String description,
    String? photoUrl,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,

        'photo_urls': photoUrl,
      };
      final updatedRoute = await _supabase
          .from('routes')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return RouteModel.fromJson(updatedRoute);
    } catch (e) {
      throw 'Невозможно обновить маршрут';
    }
  }

  Future<void> deleteRoute(String routeId) async {
    try {
      await _supabase.from('routes').delete().eq('id', routeId);
    } catch (e) {
      throw 'Ошибка удаления маршрута: $e';
    }
  }

  Future<List<String>?> updateRoutePhotos({
    required List<File> files,
    required String id,
  }) async {
    try {
      final List<String> photoUrls = [];
      for (var file in files) {
        final fileName = '$id/${DateTime.now().millisecondsSinceEpoch}';
        await _supabase.storage.from(_bucketName).upload(fileName, file);
        final photoUrl = _supabase.storage
            .from(_bucketName)
            .getPublicUrl(fileName);
        photoUrls.add(photoUrl);
      }

      await _supabase
          .from('routes')
          .update({'photo_urls': photoUrls})
          .eq('id', id);
      return photoUrls;
    } catch (e) {
      throw AppException('Ошибка при загрузке фото: $e');
    }
  }

  Future<List<RouteModel>> searchRoutes({
    String? query,
    required String userId,
  }) async {
    try {
      var request = _supabase.from('routes').select(
        '''*, creator:creator_id(*)''',
      );

      if (query != null && query.isNotEmpty) {
        request = request.or('name.ilike.%$query%,description.ilike.%$query%');
      }

      final response = await request;
      return (response as List).map((item) {
        return RouteModel.fromJson(item);
      }).toList();
    } catch (e) {
      throw AppException('Ошибка поиска маршрутов: $e');
    }
  }
}
