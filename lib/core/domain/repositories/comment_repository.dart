import 'dart:io';

import 'package:travelcompanion/core/domain/entities/comment_model.dart';

abstract class CommentRepository {
  Future<CommentModel> addComment({
    required String creatorId,
    required String routeId,
    required String text,
    DateTime? createdAt,
    required List<String>? images,
    required int rating,
  });

  Future<List<CommentModel>> getComments({required String routeId});

  Future<int> getCommentsCount({required String routeId});

  Future<double?> getAverageRating({required String routeId});

  Future<List<String>?> uploadCommentPhotos({
    required List<File> files,
    required String routeId,
  });

  Future<void> deleteComment(String commentId);

  Future<CommentModel> createComment({
    required String routeId,
    required String creatorId,
    required String text,
    required int rating,
    List<String>? images,
  });
}
