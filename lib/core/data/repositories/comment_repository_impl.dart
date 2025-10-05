import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/core/domain/entities/comment_model.dart';
import 'package:travelcompanion/core/domain/repositories/comment_repository.dart';
import 'package:travelcompanion/core/domain/exceptions/app_exception.dart';

class CommentRepositoryImpl implements CommentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<CommentModel>> getComments({required String routeId}) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('*, creator:users(*)')
          .eq('route_id', routeId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CommentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw AppException('Ошибка получения комментариев: $e');
    }
  }

  @override
  Future<int> getCommentsCount({required String routeId}) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('id')
          .eq('route_id', routeId);

      return (response as List).length;
    } catch (e) {
      throw AppException('Ошибка получения количества комментариев: $e');
    }
  }

  @override
  Future<double?> getAverageRating({required String routeId}) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('rating')
          .eq('route_id', routeId);

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
  Future<CommentModel> createComment({
    required String routeId,
    required String creatorId,
    required String text,
    required int rating,
    List<String>? images,
  }) async {
    try {
      final response = await _supabase
          .from('comments')
          .insert({
            'route_id': routeId,
            'creator_id': creatorId,
            'text': text,
            'rating': rating,
            'images': images ?? [],
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('*, creator:users(*)')
          .single();

      return CommentModel.fromJson(response);
    } catch (e) {
      throw AppException('Ошибка создания комментария: $e');
    }
  }

  @override
  Future<CommentModel> addComment({
    required String creatorId,
    required String routeId,
    required String text,
    DateTime? createdAt,
    required List<String>? images,
    required int rating,
  }) async {
    return await createComment(
      routeId: routeId,
      creatorId: creatorId,
      text: text,
      rating: rating,
      images: images,
    );
  }

  @override
  Future<List<String>?> uploadCommentPhotos({
    required List<File> files,
    required String routeId,
  }) async {
    try {
      List<String> photoUrls = [];
      for (var file in files) {
        final fileName = '$routeId/${DateTime.now().millisecondsSinceEpoch}';
        await _supabase.storage.from('comment-photos').upload(fileName, file);
        final photoUrl = _supabase.storage
            .from('comment-photos')
            .getPublicUrl(fileName);
        photoUrls.add(photoUrl);
      }
      return photoUrls;
    } catch (e) {
      throw AppException('Ошибка загрузки фото комментария: $e');
    }
  }

  @override
  Future<void> deleteComment(String id) async {
    try {
      await _supabase.from('comments').delete().eq('id', id);
    } catch (e) {
      throw AppException('Ошибка удаления комментария: $e');
    }
  }
}
