import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/details_route/data/models/comment_model.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/comment_rep_provider.dart';

final commentsProvider = FutureProvider.family<List<CommentModel>, String>((
  ref,
  routeId,
) async {
  return await ref
      .read(commentRepositoryProvider)
      .getComments(routeId: routeId);
});
