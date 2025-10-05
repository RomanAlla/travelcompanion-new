import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/entities/route_details.dart';

import 'package:travelcompanion/core/presentation/providers/use_cases_providers.dart';

final routeDetailsProvider = FutureProvider.family<RouteDetailsModel, String>((
  ref,
  routeId,
) async {
  final useCase = ref.watch(getRouteDetailsUseCaseProvider);
  return await useCase.call(routeId);
});

final addToFavouritesProvider = FutureProvider.family((
  ref,
  AddToFavouritesParams params,
) async {
  final useCase = ref.watch(addToFavouritesUseCaseProvider);
  return await useCase.call(userId: params.userId, routeId: params.routeId);
});

final removeFromFavouritesProvider = FutureProvider.family((
  ref,
  RemoveFromFavouritesParams params,
) async {
  final useCase = ref.watch(removeFromFavouritesUseCaseProvider);
  return await useCase.call(userId: params.userId, routeId: params.routeId);
});

class CreateRouteParams {
  final String creatorId;
  final String name;
  final String description;
  final List<String>? photoUrls;
  final int travelDuration;

  CreateRouteParams({
    required this.creatorId,
    required this.name,
    required this.description,
    this.photoUrls,
    required this.travelDuration,
  });
}

class AddToFavouritesParams {
  final String userId;
  final String routeId;

  AddToFavouritesParams({required this.userId, required this.routeId});
}

class RemoveFromFavouritesParams {
  final String userId;
  final String routeId;

  RemoveFromFavouritesParams({required this.userId, required this.routeId});
}
