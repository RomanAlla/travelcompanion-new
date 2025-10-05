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
