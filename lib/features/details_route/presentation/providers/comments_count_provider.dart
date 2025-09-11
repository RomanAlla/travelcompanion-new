import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/comment_rep_provider.dart';

final commentsCountProvider = FutureProvider.autoDispose.family<int, String>((
  ref,
  routeId,
) async {
  return ref
      .watch(commentRepositoryProvider)
      .getCommentsCount(routeId: routeId);
});
