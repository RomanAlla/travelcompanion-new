import 'package:travelcompanion/core/domain/entities/comment_model.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/core/domain/entities/user_model.dart';

class RouteDetailsModel {
  final String routeId;
  final RouteModel route;
  final UserModel creator;
  final List<CommentModel> comments;
  final int commentsCount;
  final double? averageRating;
  final int userRoutesCount;
  final double? averageUserRoutesRating;

  RouteDetailsModel({
    required this.routeId,
    required this.route,
    required this.creator,
    required this.comments,
    required this.commentsCount,
    required this.averageRating,
    required this.userRoutesCount,
    required this.averageUserRoutesRating,
  });

  RouteDetailsModel copyWith({
    String? routeId,
    RouteModel? route,
    UserModel? creator,
    List<CommentModel>? comments,
    int? commentsCount,
    double? averageRating,
    int? userRoutesCount,
    double? averageUserRoutesRating,
  }) {
    return RouteDetailsModel(
      routeId: routeId ?? this.routeId,
      route: route ?? this.route,
      creator: creator ?? this.creator,
      comments: comments ?? this.comments,
      commentsCount: commentsCount ?? this.commentsCount,
      averageRating: averageRating ?? this.averageRating,
      userRoutesCount: userRoutesCount ?? this.userRoutesCount,
      averageUserRoutesRating:
          averageUserRoutesRating ?? this.averageUserRoutesRating,
    );
  }
}
