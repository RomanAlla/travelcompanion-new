import 'package:travelcompanion/core/domain/entities/route_model.dart';

class RouteListState {
  final RouteModel route;
  final double? rating;
  final int? userRoutesCount;
  RouteListState({
    required this.route,
    required this.rating,
    this.userRoutesCount,
  });

  RouteListState copyWith({
    RouteModel? route,
    double? rating,
    int? userRoutesCount,
  }) {
    return RouteListState(
      route: route ?? this.route,
      rating: rating ?? this.rating,
      userRoutesCount: userRoutesCount ?? this.userRoutesCount,
    );
  }
}
