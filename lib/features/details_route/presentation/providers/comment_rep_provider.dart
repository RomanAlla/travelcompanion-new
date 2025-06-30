import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/details_route/data/repository/comment_repository.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository();
});
