import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_repository_provider.dart';

final averageUserRoutesRatingProvider = FutureProvider.family<double?, String>((
  ref,
  userId,
) {
  return ref
      .watch(routeRepositoryProvider)
      .getAverageUserRoutesRating(userId: userId);
});
