import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/entities/comment_model.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/comment_rep_provider.dart';

final commentsListProvider = FutureProvider<List<CommentModel>>((ref) async {
  return await ref.read(commentRepositoryProvider).getAllComments();
});
