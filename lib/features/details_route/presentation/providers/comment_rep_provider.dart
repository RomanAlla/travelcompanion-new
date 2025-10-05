import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/data/repositories/comment_repository_impl.dart';
import 'package:travelcompanion/core/domain/repositories/comment_repository.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepositoryImpl();
});
