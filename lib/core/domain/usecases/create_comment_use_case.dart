import 'dart:io';

import 'package:travelcompanion/core/domain/exceptions/validation_exception.dart';
import 'package:travelcompanion/core/domain/repositories/comment_repository.dart';

class CreateCommentUseCase {
  final CommentRepository _commentRepository;

  CreateCommentUseCase(this._commentRepository);

  Future<void> execute({
    required String creatorId,
    required String routeId,
    required String text,
    required int rating,
    List<String>? imagePaths,
  }) async {
    if (rating == 0) throw ValidationException('Поставьте оценку');
    if (text.isEmpty) throw ValidationException('Напишите текст отзыва');
    if (text.length < 10) {
      throw ValidationException('Отзыв должен содержать минимум 10 символов');
    }

    List<String> imageUrls = [];

    if (imagePaths != null && imagePaths.isNotEmpty) {
      final files = imagePaths.map((path) => File(path)).toList();
      imageUrls =
          await _commentRepository.uploadCommentPhotos(
            files: files,
            routeId: routeId,
          ) ??
          [];
    }

    await _commentRepository.addComment(
      creatorId: creatorId,
      routeId: routeId,
      text: text,
      images: imageUrls.isNotEmpty ? imageUrls : null,
      rating: rating,
    );
  }
}
