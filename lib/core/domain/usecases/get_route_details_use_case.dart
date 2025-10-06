import 'package:travelcompanion/core/domain/entities/route_details.dart';
import 'package:travelcompanion/core/domain/repositories/route_repository.dart';
import 'package:travelcompanion/core/domain/repositories/comment_repository.dart';

class GetRouteDetailsUseCase {
  final RouteRepository _routeRepository;
  final CommentRepository _commentRepository;

  GetRouteDetailsUseCase(this._routeRepository, this._commentRepository);

  Future<RouteDetailsModel> call(String routeId) async {
    final route = await _routeRepository.getRoutesById(id: routeId);

    final comments = await _commentRepository.getComments(routeId: routeId);

    final commentsCount = await _commentRepository.getCommentsCount(
      routeId: routeId,
    );

    final averageRating = await _commentRepository.getAverageRating(
      routeId: routeId,
    );

    final userRoutesCount = await _routeRepository.getUserRoutesCount(
      creatorId: route.creatorId,
    );

    final averageUserRoutesRating = await _routeRepository
        .getAverageUserRoutesRating(userId: route.creatorId);

    if (route.creator == null) {
      throw Exception('Route creator not found');
    }

    return RouteDetailsModel(
      routeId: routeId,
      route: route,
      creator: route.creator!,
      comments: comments,
      commentsCount: commentsCount,
      averageRating: averageRating,
      userRoutesCount: userRoutesCount ?? 0,
      averageUserRoutesRating: averageUserRoutesRating,
    );
  }
}
