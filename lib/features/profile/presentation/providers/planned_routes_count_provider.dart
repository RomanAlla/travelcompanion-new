import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/presentation/providers/use_cases_providers.dart';

final plannedRoutesCountProvider = FutureProvider.family<int, String>((
  ref,
  userId,
) async {
  return await ref
      .read(favouriteRepositoryProvider)
      .getUserFavouriteLength(userId: userId);
});
