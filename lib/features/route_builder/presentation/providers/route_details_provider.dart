import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/features/auth/data/models/user_model.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/comment_rep_provider.dart';
import 'package:travelcompanion/features/route_builder/data/models/route_details.dart';
import 'package:travelcompanion/features/route_builder/data/models/route_model.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_repository_provider.dart';

final routeDetailsProvider = FutureProvider.family<RouteDetails, RouteModel>((
  ref,
  route,
) async {
  final commentRepo = ref.read(commentRepositoryProvider);
  final routeRepo = ref.read(routeRepositoryProvider);
  final user = await Supabase.instance.client
      .from('users')
      .select()
      .eq('id', route.creator!.id)
      .maybeSingle();
  final creator = user != null ? UserModel.fromJson(user) : null;
  final commentsList = await commentRepo.getComments(routeId: route.id);
  final commentsCount = await commentRepo.getCommentsCount(routeId: route.id);
  final averageRating = await commentRepo.getAverageRating(routeId: route.id);
  final userRoutesCount = await routeRepo.getUserRoutesCount(
    creatorId: route.creator!.id,
  );
  final averageUserRoutesRating = await routeRepo.getAverageUserRoutesRating(
    userId: route.creator!.id,
  );

  final myItems = route.photoUrls
      .map(
        (url) => SizedBox(
          width: double.infinity,
          child: Image.network(url, fit: BoxFit.cover),
        ),
      )
      .toList();
  return RouteDetails(
    creator: creator!,
    commentsList: commentsList,
    commentsCount: commentsCount,
    averageRating: averageRating,
    userRoutesCount: userRoutesCount,
    averageUserRoutesRating: averageUserRoutesRating,
    myItems: myItems,
    currentIndex: 0,
  );
});
