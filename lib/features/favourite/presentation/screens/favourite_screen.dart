import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/error/error_handler.dart';
import 'package:travelcompanion/features/details_route/presentation/screens/route_description_screen.dart';
import 'package:travelcompanion/features/favourite/presentation/widgets/empty_state_widget.dart';
import 'package:travelcompanion/features/favourite/presentation/widgets/error_state_widget.dart';
import 'package:travelcompanion/features/favourite/presentation/widgets/loading_state_widget.dart';
import 'package:travelcompanion/features/favourite/presentation/widgets/stats_widget.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';
import 'package:travelcompanion/features/routes/presentation/providers/favourite_repository_provider.dart';
import 'package:travelcompanion/features/routes/presentation/providers/route_repository_provider.dart';
import 'package:travelcompanion/core/widgets/route_card_widget.dart';

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
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue[700]!, Colors.blue[500]!],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Избранное',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ваши сохраненные маршруты',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
                          child: RouteCardWidget(
                            route: route,
                            onTap: () => _toDescriptionScreen(route),
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
