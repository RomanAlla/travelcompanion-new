import 'package:travelcompanion/core/domain/entities/route_model.dart';

abstract class FavouriteRepository {
  Future<void> addToFavourite({
    required String userId,
    required String routeId,
  });

  Future<void> removeFromFavourites({
    required String userId,
    required String routeId,
  });

  Future<List<RouteModel>> getUserFavourites({required String userId});

  Future<bool> isFavourite({required String userId, required String routeId});
}
