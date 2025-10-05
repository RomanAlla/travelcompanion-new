import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/exceptions/error_handler.dart';
import 'package:travelcompanion/core/presentation/widgets/app_bar.dart';

import 'package:travelcompanion/features/details_route/presentation/screens/route_description_screen.dart';
import 'package:travelcompanion/features/favourite/presentation/widgets/empty_state_widget.dart';
import 'package:travelcompanion/features/favourite/presentation/widgets/error_state_widget.dart';
import 'package:travelcompanion/features/favourite/presentation/widgets/loading_state_widget.dart';
import 'package:travelcompanion/features/favourite/presentation/widgets/stats_widget.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/favourite_repository_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_repository_provider.dart';
import 'package:travelcompanion/core/presentation/widgets/route_card_widget.dart';

@RoutePage()
class FavouriteScreen extends ConsumerStatefulWidget {
  const FavouriteScreen({super.key});

  @override
  ConsumerState<FavouriteScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<FavouriteScreen> {
  Future<void> _toDescriptionScreen(RouteModel route) async {
    try {
      final rep = ref.read(routeRepositoryProvider);
      final completeRoute = await rep.getRoutesById(id: route.id);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RouteDescriptionScreen(
              routeId: completeRoute.id,
              route: completeRoute,
            ),
          ),
        );
      }
    } catch (e) {
      ErrorHandler.getErrorMessage(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favouriteList = ref.watch(favouriteListProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 50,
            pinned: true,
            flexibleSpace: AppBarWidget(title: 'Избранное'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: favouriteList.when(
                data: (favouriteList) {
                  if (favouriteList.isEmpty) {
                    return EmptyStateWidget();
                  }
                  return Column(
                    children: [
                      StatsWidget(lenght: favouriteList.length),
                      const SizedBox(height: 16),
                      ...favouriteList.map(
                        (route) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Stack(
                            children: [
                              RouteCardWidget(
                                canDelete: true,
                                route: route,
                                onTap: () => _toDescriptionScreen(route),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                error: (error, _) => ErrorStateWidget(error: error),
                loading: () => LoadingStateWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
