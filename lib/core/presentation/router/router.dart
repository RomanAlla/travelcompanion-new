import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:travelcompanion/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:travelcompanion/features/details_route/presentation/screens/full_screen_comment_photos_screen.dart';
import 'package:travelcompanion/features/details_route/presentation/screens/route_description_screen.dart';
import 'package:travelcompanion/features/favourite/presentation/screens/favourite_screen.dart';
import 'package:travelcompanion/features/home/presentation/home_screen.dart';
import 'package:travelcompanion/features/main/presentation/screens/main_routes_screen.dart';
import 'package:travelcompanion/features/map/domain/enums/map_mode.dart';
import 'package:travelcompanion/features/map/presentation/screens/map_screen.dart';
import 'package:travelcompanion/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:travelcompanion/features/route_builder/presentation/screens/create_route_screen.dart';
import 'package:travelcompanion/features/route_builder/presentation/screens/point_description_screen.dart';
import 'package:travelcompanion/features/profile/presentation/screens/profile_screen.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/features/search/presentation/screens/search_main_screen.dart';
import 'package:travelcompanion/features/travels/presentation/screens/travels_screen.dart';
import 'package:travelcompanion/features/user_routes/presentation/user_routes.dart';
part 'router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  final WidgetRef ref;

  AuthGuard(this.ref);

  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    try {
      await ref.read(appInitializationProvider.future);
      final user = ref.read(currentUserProvider);
      final isAuthRoute =
          resolver.route.name == SignInRoute.name ||
          resolver.route.name == SignUpRoute.name;
      final isAuthenticated = user != null;

      if (!isAuthenticated && !isAuthRoute) {
        router.replace(const SignInRoute());
      } else if (isAuthenticated && isAuthRoute) {
        router.replace(const HomeRoute());
      } else {
        resolver.next(true);
      }
    } catch (e) {
      router.replace(const SignInRoute());
    }
  }
}

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final AuthGuard authGuard;

  AppRouter({required this.authGuard});
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRoute.page,
      path: '/',
      guards: [authGuard],
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
      guards: [authGuard],
      children: [AutoRoute(page: RouteDescriptionRoute.page)],
    ),
    AutoRoute(
      page: UserRoutesRoute.page,
      path: '/user-routes',
      guards: [authGuard],
    ),
    AutoRoute(
      page: RouteDescriptionRoute.page,
      path: '/route-description',
      guards: [authGuard],
    ),
    AutoRoute(page: MapRoute.page, guards: [authGuard]),
    AutoRoute(page: SignInRoute.page, path: '/sign-in', initial: true),
    AutoRoute(page: SignUpRoute.page, path: '/sign-up'),

    AutoRoute(
      page: CreateRouteRoute.page,
      path: '/create-route',
      guards: [authGuard],
    ),
    AutoRoute(page: EditProfileRoute.page, guards: [authGuard]),

    AutoRoute(page: PointDescriptionRoute.page, guards: [authGuard]),
    AutoRoute(page: FullRouteCommentPhotosRoute.page, guards: [authGuard]),
  ];
}
