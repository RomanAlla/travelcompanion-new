import 'package:flutter/material.dart';
import 'package:travelcompanion/features/auth/data/models/user_model.dart';

import 'package:travelcompanion/features/details_route/data/models/comment_model.dart';
import 'package:travelcompanion/features/route_builder/data/models/route_model.dart';

class RouteDetails {
  final List<CommentModel> commentsList;
  final int? commentsCount;
  final double? averageRating;
  final int? userRoutesCount;
  final double? averageUserRoutesRating;
  final List<Widget> myItems;
  final int currentIndex;
  final UserModel creator;
  final RouteModel route;

  RouteDetails({
    required this.commentsList,
    required this.commentsCount,
    required this.averageRating,
    required this.userRoutesCount,
    required this.averageUserRoutesRating,
    required this.myItems,
    required this.currentIndex,
    required this.creator,
    required this.route,
  });
}
