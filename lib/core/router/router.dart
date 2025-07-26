import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:travelcompanion/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:travelcompanion/features/details_route/presentation/screens/full_screen_comment_photos_screen.dart';
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
import 'package:travelcompanion/features/routes/data/models/interesting_route_points_model.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';
import 'package:travelcompanion/features/search/presentation/screens/search_main_screen.dart';
import 'package:travelcompanion/features/travels/presentation/screens/travels_screen.dart';
import 'package:travelcompanion/features/user_routes/presentation/user_routes.dart';
part 'router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final isAuthenticated =
        Supabase.instance.client.auth.currentSession != null;
    final isAuthRoute =
        resolver.route.name == SignInRoute.name ||
        resolver.route.name == SignUpRoute.name;

    if (!isAuthenticated && !isAuthRoute) {
      router.replace(const SignInRoute());
    } else if (isAuthenticated && isAuthRoute) {
      router.replace(const HomeRoute());
    } else {
      resolver.next(true);
    }
  }
}

final _authGuard = AuthGuard();

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRoute.page,
      path: '/',
      guards: [_authGuard],
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
      guards: [_authGuard],
      children: [AutoRoute(page: RouteDescriptionRoute.page)],
    ),
    AutoRoute(
      page: UserRoutesRoute.page,
      path: '/user-routes',
      guards: [_authGuard],
    ),
    AutoRoute(
      page: RouteDescriptionRoute.page,
      path: '/route-description',
      guards: [_authGuard],
    ),
    AutoRoute(page: SignInRoute.page, path: '/sign-in', initial: true),
    AutoRoute(page: SignUpRoute.page, path: '/sign-up'),
    AutoRoute(page: MapChangeModeRoute.page, guards: [_authGuard]),
    AutoRoute(page: MapWatchModeRoute.page, guards: [_authGuard]),
    AutoRoute(
      page: CreateRouteRoute.page,
      path: '/create-route',
      guards: [_authGuard],
    ),
    AutoRoute(page: InterestingPointsMapRoute.page, guards: [_authGuard]),
    AutoRoute(page: PointDescriptionRoute.page, guards: [_authGuard]),
    AutoRoute(page: MapRoute.page, guards: [_authGuard]),
    AutoRoute(page: FullRouteCommentPhotosRoute.page, guards: [_authGuard]),
  ];
}
