import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/core/domain/repositories/route_repository.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/core/domain/exceptions/app_exception.dart';

class RouteRepositoryImpl implements RouteRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<RouteModel> createRoute({
    required String creatorId,
    required String name,
    required String description,
    List<String>? photoUrls,
    required int travelDuration,
  }) async {
    try {
      final response = await _supabase
          .from('routes')
          .insert({
            'creator_id': creatorId,
            'name': name,
            'description': description,
            'photo_urls': photoUrls ?? [],
            'travel_duration': travelDuration,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return RouteModel.fromJson(response);
    } catch (e) {
      throw AppException('Ошибка создания маршрута: $e');
    }
  }

  @override
  Future<RouteModel> getRoutesById({required String id}) async {
    try {
      final response = await _supabase
          .from('routes')
          .select('*, creator:users(*)')
          .eq('id', id)
          .single();

      return RouteModel.fromJson(response);
    } catch (e) {
      throw AppException('Ошибка получения маршрута: $e');
    }
  }

  @override
  Future<List<RouteModel>> getRoutes() async {
    try {
      final response = await _supabase
          .from('routes')
          .select('*, creator:users(*)')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => RouteModel.fromJson(json))
          .toList();
    } catch (e) {
      throw AppException('Ошибка получения маршрутов: $e');
    }
  }

  @override
  Future<List<RouteModel>> searchRoutes({
    String? query,
    required String userId,
  }) async {
    try {
      var builder = _supabase.from('routes').select('*, creator:users(*)');

      if (query != null && query.isNotEmpty) {
        builder = builder.ilike('name', '%$query%');
      }

      final response = await builder.order('created_at', ascending: false);
      return (response as List)
          .map((json) => RouteModel.fromJson(json))
          .toList();
    } catch (e) {
      throw AppException('Ошибка поиска маршрутов: $e');
    }
  }

  @override
  Future<void> updateRoute({
    required String id,
    String? name,
    String? description,
    List<String>? photoUrls,
    int? travelDuration,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (photoUrls != null) updateData['photo_urls'] = photoUrls;
      if (travelDuration != null) {
        updateData['travel_duration'] = travelDuration;
      }

      await _supabase.from('routes').update(updateData).eq('id', id);
    } catch (e) {
      throw AppException('Ошибка обновления маршрута: $e');
    }
  }

  @override
  Future<void> deleteRoute(String id) async {
    try {
      await _supabase.from('routes').delete().eq('id', id);
    } catch (e) {
      throw AppException('Ошибка удаления маршрута: $e');
    }
  }

  @override
  Future<int?> getUserRoutesCount({required String creatorId}) async {
    try {
      final response = await _supabase
          .from('routes')
          .select('id')
          .eq('creator_id', creatorId);

      return (response as List).length;
    } catch (e) {
      throw AppException('Ошибка получения количества маршрутов: $e');
    }
  }

  @override
  Future<double?> getAverageUserRoutesRating({required String userId}) async {
    try {
      final routes = await _supabase
          .from('routes')
          .select('id')
          .eq('creator_id', userId);

      if (routes.isEmpty) return null;

      final response = await _supabase
          .from('comments')
          .select('rating')
          .inFilter('route_id', routes.map((r) => r['id']).toList());

      if (response.isEmpty) return null;

      final ratings = (response as List)
          .map((r) => r['rating'] as int)
          .toList();
      return ratings.reduce((a, b) => a + b) / ratings.length;
    } catch (e) {
      throw AppException('Ошибка получения среднего рейтинга: $e');
    }
  }

  @override
  Future<List<RouteModel>> getUserRoutes({required String creatorId}) async {
    try {
      final response = await _supabase
          .from('routes')
          .select('*, creator:users(*)')
          .eq('creator_id', creatorId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => RouteModel.fromJson(json))
          .toList();
    } catch (e) {
      throw AppException('Ошибка получения маршрутов пользователя: $e');
    }
  }

  @override
  Future<List<String>> updateRoutePhotos({
    required List<File> files,
    required String id,
  }) async {
    try {
      List<String> photoUrls = [];
      for (final file in files) {
        final path = '$id/${file.path}${DateTime.now()}';
        await _supabase.storage.from('routes-photos').upload(path, file);

        final photoUrl = _supabase.storage
            .from('routes-photos')
            .getPublicUrl(path);
        photoUrls.add(photoUrl);
      }
      await _supabase
          .from('routes')
          .update({'photo_urls': photoUrls})
          .eq('id', id);
      return photoUrls;
    } catch (e) {
      throw AppException('Ошибка обновления фото: $e');
    }
  }

  @override
  Future<double> getAverageRouteRating(String id) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('rating')
          .eq('route_id', id);

      final data = response as List<dynamic>;

      if (data.isEmpty) {
        return 0.0;
      }

      double totalRating = 0;
      for (var item in data) {
        totalRating += (item['rating'] as int).toDouble();
      }
      return totalRating / data.length;
    } catch (e) {
      throw AppException('Ошибка получения среднего рейтинга маршрута: $e');
    }
  }
}
