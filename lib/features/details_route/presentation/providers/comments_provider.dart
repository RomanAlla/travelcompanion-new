import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/entities/comment_model.dart';
import 'package:travelcompanion/core/presentation/providers/use_cases_providers.dart';

final commentsProvider = FutureProvider.family<List<CommentModel>, String>((
  ref,
  routeId,
) async {
  return await ref
      .watch(commentRepositoryProvider)
      .getComments(routeId: routeId);
});
