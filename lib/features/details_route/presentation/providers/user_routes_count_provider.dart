import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_repository_provider.dart';

final userRoutesCountProvider = FutureProvider.family<int?, String>((
  ref,
  creatorId,
) {
  return ref
      .watch(routeRepositoryProvider)
      .getUserRoutesCount(creatorId: creatorId);
});
