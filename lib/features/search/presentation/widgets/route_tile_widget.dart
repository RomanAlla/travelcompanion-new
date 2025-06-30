import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/details_route/presentation/screens/route_description_screen.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';
import 'package:travelcompanion/features/routes/presentation/providers/route_repository_provider.dart';

class RouteTileWidget extends ConsumerWidget {
  final RouteModel route;
  const RouteTileWidget({super.key, required this.route});
  Future<void> navigateToRouteDetails(WidgetRef ref, context) async {
    final routeRepository = ref.read(routeRepositoryProvider);
    final completeRoute = await routeRepository.getRoutesById(id: route.id);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RouteDescriptionScreen(
              routeId: completeRoute.id, route: completeRoute),
        ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () => navigateToRouteDetails(ref, context),
      title: Text(route.name),
      subtitle: Text(route.description!),
    );
  }
}
