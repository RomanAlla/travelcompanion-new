import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/presentation/providers/use_cases_providers.dart';

final averageRatingProvider = FutureProvider.autoDispose
    .family<double?, String>((ref, routeId) {
      return ref.read(routeRepositoryProvider).getAverageRouteRating(routeId);
    });
