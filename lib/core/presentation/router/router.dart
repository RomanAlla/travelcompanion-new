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
import 'package:travelcompanion/core/presentation/screens/splash_screen.dart';
import 'package:travelcompanion/features/chat/presentation/screens/chat_screen.dart';
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
      final authState = ref.watch(authProvider);
      final isLoading = authState.isLoading;
      final user = authState.user;
      final isAuthRoute =
          resolver.route.name == SignInRoute.name ||
          resolver.route.name == SignUpRoute.name;
      final isSplashRoute = resolver.route.name == SplashRoute.name;
      final isAuthenticated = user != null;

      // Если идет загрузка и это не splash screen, разрешаем навигацию только на splash
      if (isLoading && !isSplashRoute) {
        router.replacePath('/splash');
        return;
      }

      // Если загрузка завершена и мы на splash screen, перенаправляем
      if (!isLoading && isSplashRoute) {
        if (isAuthenticated) {
          router.replacePath('/');
        } else {
          router.replacePath('/sign-in');
        }
        return;
      }

      // Обычная логика проверки авторизации
      if (!isAuthenticated && !isAuthRoute && !isSplashRoute) {
        router.replacePath('/sign-in');
      } else if (isAuthenticated && isAuthRoute) {
        router.replacePath('/');
      } else {
        resolver.next(true);
      }
    } catch (e) {
      router.replacePath('/sign-in');
    }
  }
}

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final AuthGuard authGuard;

  AppRouter({required this.authGuard});
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, path: '/splash', initial: true),
    AutoRoute(
      page: HomeRoute.page,
      path: '/',
      guards: [authGuard],
      children: [
        AutoRoute(page: MainRoutesRoute.page, path: 'main'),
        AutoRoute(page: FavouriteRoute.page, path: 'favourite'),
        AutoRoute(page: ChatRoute.page, path: 'chat'),
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
    AutoRoute(page: SignInRoute.page, path: '/sign-in'),
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
