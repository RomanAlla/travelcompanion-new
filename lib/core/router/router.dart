import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:travelcompanion/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:travelcompanion/features/details_route/presentation/screens/route_description_screen.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/map_screen.dart';
import 'package:travelcompanion/features/favourite/presentation/screens/favourite_screen.dart';
import 'package:travelcompanion/features/home/presentation/home_screen.dart';
import 'package:travelcompanion/features/main/presentation/screens/main_routes_screen.dart';
import 'package:travelcompanion/features/map/screens/map_change_mode.dart';
import 'package:travelcompanion/features/map/screens/map_watch_mode.dart';
import 'package:travelcompanion/features/profile/presentation/screens/create_route_screen.dart';
import 'package:travelcompanion/features/profile/presentation/screens/interesting_points_map.dart';
import 'package:travelcompanion/features/profile/presentation/screens/point_description_screen.dart';
import 'package:travelcompanion/features/profile/presentation/screens/profile_screen.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';
import 'package:travelcompanion/features/search/presentation/screens/search_main_screen.dart';
import 'package:travelcompanion/features/travels/presentation/screens/travels_screen.dart';
import 'package:travelcompanion/features/user_routes/presentation/user_routes.dart';
part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRoute.page,
      path: '/',
      children: [
        AutoRoute(page: MainRoutesRoute.page, path: 'main'),
        AutoRoute(page: FavouriteRoute.page, path: 'favourite'),
        AutoRoute(page: TravelsRoute.page, path: 'travels'),
        AutoRoute(page: ProfileRoute.page, path: 'profile'),
      ],
    ),
    AutoRoute(
      page: SearchMainRoute.page,
      path: '/search',
      children: [AutoRoute(page: RouteDescriptionRoute.page)],
    ),
    AutoRoute(page: UserRoutesRoute.page, path: '/user-routes'),
    AutoRoute(page: RouteDescriptionRoute.page, path: '/route-description'),
    AutoRoute(page: SignInRoute.page, path: '/sign-in', initial: true),
    AutoRoute(page: SignUpRoute.page, path: '/sign-up'),
    AutoRoute(page: MapChangeModeRoute.page),
    AutoRoute(page: MapWatchModeRoute.page),
    AutoRoute(page: CreateRouteRoute.page, path: '/create-route'),
    AutoRoute(page: InterestingPointsMapRoute.page),
    AutoRoute(page: PointDescriptionRoute.page),
    AutoRoute(page: MapRoute.page),
  ];

  Future<bool> Function(NavigationResolver resolver, StackRouter router)
  get redirect => (resolver, router) async {
    final isAuthenticated =
        Supabase.instance.client.auth.currentSession != null;
    final isAuthRoute =
        resolver.route.name == SignInRoute.name ||
        resolver.route.name == SignUpRoute.name;

    if (!isAuthenticated && !isAuthRoute) {
      await router.replace(const SignInRoute());
      return true;
    }

    if (isAuthenticated && isAuthRoute) {
      await router.replace(const HomeRoute());
      return true;
    }

    return false;
  };
}
