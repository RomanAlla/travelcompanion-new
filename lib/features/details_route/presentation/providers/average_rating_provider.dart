import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/comment_rep_provider.dart';

final averageRatingProvider = FutureProvider.autoDispose
    .family<double?, String>((ref, routeId) {
      return ref
          .watch(commentRepositoryProvider)
          .getAverageRating(routeId: routeId);
    });
