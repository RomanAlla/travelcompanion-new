import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/presentation/providers/use_cases_providers.dart';

final averageUserRoutesRatingProvider = FutureProvider.family<double?, String>((
  ref,
  userId,
) {
  return ref
      .read(routeRepositoryProvider)
      .getAverageUserRoutesRating(userId: userId);
});
