import 'package:travelcompanion/core/domain/entities/route_details.dart';
import 'package:travelcompanion/core/domain/repositories/route_repository.dart';
import 'package:travelcompanion/core/domain/repositories/comment_repository.dart';

/// Use Case для получения детальной информации о маршруте
/// Следует принципу Single Responsibility - решает одну бизнес-задачу
class GetRouteDetailsUseCase {
  final RouteRepository _routeRepository;
  final CommentRepository _commentRepository;

  GetRouteDetailsUseCase(this._routeRepository, this._commentRepository);

  /// Получить детальную информацию о маршруте
  ///
  /// [routeId] - ID маршрута
  ///
  /// Возвращает [RouteDetailsModel] с полной информацией о маршруте
  Future<RouteDetailsModel> call(String routeId) async {
    // Получаем основную информацию о маршруте
    final route = await _routeRepository.getRoutesById(id: routeId);

    // Получаем комментарии к маршруту
    final comments = await _commentRepository.getComments(routeId: routeId);

    // Получаем количество комментариев
    final commentsCount = await _commentRepository.getCommentsCount(
      routeId: routeId,
    );

    // Получаем средний рейтинг маршрута
    final averageRating = await _commentRepository.getAverageRating(
      routeId: routeId,
    );

    // Получаем количество маршрутов создателя
    final userRoutesCount = await _routeRepository.getUserRoutesCount(
      creatorId: route.creatorId,
    );

    // Получаем средний рейтинг всех маршрутов создателя
    final averageUserRoutesRating = await _routeRepository
        .getAverageUserRoutesRating(userId: route.creatorId);

    // Проверяем, что у маршрута есть создатель
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
