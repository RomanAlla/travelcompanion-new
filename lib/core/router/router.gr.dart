// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [CreateRouteScreen]
class CreateRouteRoute extends PageRouteInfo<void> {
  const CreateRouteRoute({List<PageRouteInfo>? children})
    : super(CreateRouteRoute.name, initialChildren: children);

  static const String name = 'CreateRouteRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreateRouteScreen();
    },
  );
}

/// generated route for
/// [FavouriteScreen]
class FavouriteRoute extends PageRouteInfo<void> {
  const FavouriteRoute({List<PageRouteInfo>? children})
    : super(FavouriteRoute.name, initialChildren: children);

  static const String name = 'FavouriteRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FavouriteScreen();
    },
  );
}

/// generated route for
/// [FullScreenCommentPhotosScreen]
class FullRouteCommentPhotosRoute
    extends PageRouteInfo<FullRouteCommentPhotosRouteArgs> {
  FullRouteCommentPhotosRoute({
    Key? key,
    required List<String> imageUrls,
    int initialIndex = 0,
    List<PageRouteInfo>? children,
  }) : super(
         FullRouteCommentPhotosRoute.name,
         args: FullRouteCommentPhotosRouteArgs(
           key: key,
           imageUrls: imageUrls,
           initialIndex: initialIndex,
         ),
         initialChildren: children,
       );

  static const String name = 'FullRouteCommentPhotosRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FullRouteCommentPhotosRouteArgs>();
      return FullScreenCommentPhotosScreen(
        key: args.key,
        imageUrls: args.imageUrls,
        initialIndex: args.initialIndex,
      );
    },
  );
}

class FullRouteCommentPhotosRouteArgs {
  const FullRouteCommentPhotosRouteArgs({
    this.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final Key? key;

  final List<String> imageUrls;

  final int initialIndex;

  @override
  String toString() {
    return 'FullRouteCommentPhotosRouteArgs{key: $key, imageUrls: $imageUrls, initialIndex: $initialIndex}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FullRouteCommentPhotosRouteArgs) return false;
    return key == other.key &&
        const ListEquality().equals(imageUrls, other.imageUrls) &&
        initialIndex == other.initialIndex;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const ListEquality().hash(imageUrls) ^
      initialIndex.hashCode;
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [MainRoutesScreen]
class MainRoutesRoute extends PageRouteInfo<void> {
  const MainRoutesRoute({List<PageRouteInfo>? children})
    : super(MainRoutesRoute.name, initialChildren: children);

  static const String name = 'MainRoutesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainRoutesScreen();
    },
  );
}

/// generated route for
/// [MapScreen]
class MapRoute extends PageRouteInfo<MapRouteArgs> {
  MapRoute({Key? key, required bool showObjects, List<PageRouteInfo>? children})
    : super(
        MapRoute.name,
        args: MapRouteArgs(key: key, showObjects: showObjects),
        initialChildren: children,
      );

  static const String name = 'MapRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MapRouteArgs>();
      return MapScreen(key: args.key, showObjects: args.showObjects);
    },
  );
}

class MapRouteArgs {
  const MapRouteArgs({this.key, required this.showObjects});

  final Key? key;

  final bool showObjects;

  @override
  String toString() {
    return 'MapRouteArgs{key: $key, showObjects: $showObjects}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MapRouteArgs) return false;
    return key == other.key && showObjects == other.showObjects;
  }

  @override
  int get hashCode => key.hashCode ^ showObjects.hashCode;
}

/// generated route for
/// [PointDescriptionScreen]
class PointDescriptionRoute extends PageRouteInfo<PointDescriptionRouteArgs> {
  PointDescriptionRoute({
    Key? key,
    required LatLng selectedPoint,
    List<PageRouteInfo>? children,
  }) : super(
         PointDescriptionRoute.name,
         args: PointDescriptionRouteArgs(
           key: key,
           selectedPoint: selectedPoint,
         ),
         initialChildren: children,
       );

  static const String name = 'PointDescriptionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PointDescriptionRouteArgs>();
      return PointDescriptionScreen(
        key: args.key,
        selectedPoint: args.selectedPoint,
      );
    },
  );
}

class PointDescriptionRouteArgs {
  const PointDescriptionRouteArgs({this.key, required this.selectedPoint});

  final Key? key;

  final LatLng selectedPoint;

  @override
  String toString() {
    return 'PointDescriptionRouteArgs{key: $key, selectedPoint: $selectedPoint}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PointDescriptionRouteArgs) return false;
    return key == other.key && selectedPoint == other.selectedPoint;
  }

  @override
  int get hashCode => key.hashCode ^ selectedPoint.hashCode;
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [RouteDescriptionScreen]
class RouteDescriptionRoute extends PageRouteInfo<RouteDescriptionRouteArgs> {
  RouteDescriptionRoute({
    Key? key,
    required String routeId,
    required RouteModel route,
    List<PageRouteInfo>? children,
  }) : super(
         RouteDescriptionRoute.name,
         args: RouteDescriptionRouteArgs(
           key: key,
           routeId: routeId,
           route: route,
         ),
         initialChildren: children,
       );

  static const String name = 'RouteDescriptionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RouteDescriptionRouteArgs>();
      return RouteDescriptionScreen(
        key: args.key,
        routeId: args.routeId,
        route: args.route,
      );
    },
  );
}

class RouteDescriptionRouteArgs {
  const RouteDescriptionRouteArgs({
    this.key,
    required this.routeId,
    required this.route,
  });

  final Key? key;

  final String routeId;

  final RouteModel route;

  @override
  String toString() {
    return 'RouteDescriptionRouteArgs{key: $key, routeId: $routeId, route: $route}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RouteDescriptionRouteArgs) return false;
    return key == other.key && routeId == other.routeId && route == other.route;
  }

  @override
  int get hashCode => key.hashCode ^ routeId.hashCode ^ route.hashCode;
}

/// generated route for
/// [SearchMainScreen]
class SearchMainRoute extends PageRouteInfo<void> {
  const SearchMainRoute({List<PageRouteInfo>? children})
    : super(SearchMainRoute.name, initialChildren: children);

  static const String name = 'SearchMainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SearchMainScreen();
    },
  );
}

/// generated route for
/// [SignInScreen]
class SignInRoute extends PageRouteInfo<void> {
  const SignInRoute({List<PageRouteInfo>? children})
    : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignInScreen();
    },
  );
}

/// generated route for
/// [SignUpScreen]
class SignUpRoute extends PageRouteInfo<void> {
  const SignUpRoute({List<PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignUpScreen();
    },
  );
}

/// generated route for
/// [TravelsScreen]
class TravelsRoute extends PageRouteInfo<void> {
  const TravelsRoute({List<PageRouteInfo>? children})
    : super(TravelsRoute.name, initialChildren: children);

  static const String name = 'TravelsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TravelsScreen();
    },
  );
}

/// generated route for
/// [UserRoutesScreen]
class UserRoutesRoute extends PageRouteInfo<void> {
  const UserRoutesRoute({List<PageRouteInfo>? children})
    : super(UserRoutesRoute.name, initialChildren: children);

  static const String name = 'UserRoutesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UserRoutesScreen();
    },
  );
}
