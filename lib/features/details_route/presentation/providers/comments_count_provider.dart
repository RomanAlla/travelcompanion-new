import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/presentation/providers/use_cases_providers.dart';

final commentsCountProvider = FutureProvider.autoDispose.family<int, String>((
  ref,
  routeId,
) async {
  return await ref
      .watch(commentRepositoryProvider)
      .getCommentsCount(routeId: routeId);
});
