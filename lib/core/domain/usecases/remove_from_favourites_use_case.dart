import 'package:travelcompanion/core/domain/repositories/favourite_repository.dart';

class AddToFavouritesUseCase {
  final FavouriteRepository _favouriteRepository;

  AddToFavouritesUseCase(this._favouriteRepository);

  Future<void> call({required String userId, required String routeId}) async {
    final isFavourite = await _favouriteRepository.isFavourite(
      userId: userId,
      routeId: routeId,
    );

    if (isFavourite) {
      throw Exception('Маршрут уже добавлен в избранное');
    }

    await _favouriteRepository.addToFavourite(userId: userId, routeId: routeId);
  }
}
