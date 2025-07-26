import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';
import 'package:travelcompanion/features/favourite/data/repository/favourite_repository.dart';

final favouriteRepository = Provider<FavouriteRepository>((ref) {
  return FavouriteRepository();
});

final favouriteListProvider = FutureProvider.autoDispose<List<RouteModel>>((
  ref,
) async {
  final rep = ref.watch(favouriteRepository);
  final user = ref.watch(authProvider).user;
  return await rep.getFavouriteRoutes(userId: user!.id);
});
