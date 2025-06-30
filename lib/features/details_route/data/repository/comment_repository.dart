import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/features/details_route/data/models/comment_model.dart';
import 'package:travelcompanion/core/service/supabase_service.dart';

class CommentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _bucketName = 'comment-photos';
  final SupabaseService _supabaseService = SupabaseService(
    Supabase.instance.client,
  );

  Future<CommentModel> addComment({
    required String creatorId,
    required String routeId,
    required String text,
    DateTime? createdAt,
    required List<String>? images,
    required int rating,
  }) async {
    try {
      final data = {
        'creator_id': creatorId,
        'route_id': routeId,
        'text': text,
        'images': images,
        'rating': rating,
      };

      final response = await _supabase
          .from('comments')
          .insert(data)
          .select()
          .single();

      return CommentModel.fromJson(response);
    } catch (e) {
      print(e.toString());
      throw 'add comment error';
    }
  }

  Future<int> getCommentsCount({required String routeId}) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('count')
          .eq('route_id::text', routeId);

      return response.first['count'] as int;
    } catch (e) {
      print(e.toString());
      throw 'Ошибка получения количества комментариев';
    }
  }

  Future<double?> getAverageRating({required String routeId}) async {
    try {
      final avgRating = await _supabaseService.getAvgRating(routeId);
      return avgRating;
    } catch (e) {
      print(e.toString());
      throw 'Ошибка получения среднего рейтинга';
    }
  }

  Future<List<String>?> updateCommentImages({
    required List<File> files,
    required String routeId,
  }) async {
    try {
      final List<String> photoUrls = [];
      for (var file in files) {
        final fileName = '$routeId/${DateTime.now().millisecondsSinceEpoch}';
        await _supabase.storage.from(_bucketName).upload(fileName, file);
        final photoUrl = _supabase.storage
            .from(_bucketName)
            .getPublicUrl(fileName);
        photoUrls.add(photoUrl);
      }
      await _supabase
          .from('comments')
          .update({'images': photoUrls})
          .eq('route_id', routeId);
    } catch (e) {
      print(e.toString());
      throw 'Ошибка при загрузке фото';
    }
    return null;
  }

  Future<List<CommentModel>> getComments({required String routeId}) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('''*, creator:creator_id(*)''')
          .eq('route_id::text', routeId)
          .order('created_at', ascending: false);
      final commentsList = response
          .map((response) => CommentModel.fromJson(response))
          .toList();
      return commentsList;
    } catch (e) {
      print(e.toString());
      throw 'Ошибка получения коментов';
    }
  }
}
