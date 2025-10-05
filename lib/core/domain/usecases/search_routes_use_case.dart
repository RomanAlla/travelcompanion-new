import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/core/domain/repositories/route_repository.dart';

class SearchRoutesUseCase {
  final RouteRepository _routeRepository;

  SearchRoutesUseCase(this._routeRepository);

  Future<List<RouteModel>> call({String? query, required String userId}) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    return await _routeRepository.searchRoutes(query: query, userId: userId);
  }
}
