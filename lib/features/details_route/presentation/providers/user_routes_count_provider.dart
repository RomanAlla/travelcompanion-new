import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/presentation/providers/use_cases_providers.dart';

final userRoutesCountProvider = FutureProvider.family<int?, String>((
  ref,
  creatorId,
) {
  return ref
      .watch(routeRepositoryProvider)
      .getUserRoutesCount(creatorId: creatorId);
});
