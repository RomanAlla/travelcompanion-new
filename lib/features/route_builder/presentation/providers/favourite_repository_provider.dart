import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/core/domain/repositories/favourite_repository.dart';
import 'package:travelcompanion/features/auth/presentation/providers/user_notifier_provider.dart';
import 'package:travelcompanion/features/favourite/data/repository/favourite_repository_impl.dart';

final favouriteRepository = Provider<FavouriteRepository>((ref) {
  return FavouriteRepositoryImpl();
});

final favouriteListProvider = FutureProvider.autoDispose<List<RouteModel>>((
  ref,
) async {
  final rep = ref.watch(favouriteRepository);
  final user = ref.watch(userNotifierProvider).user;
  if (user == null) {
    return [];
  }
  return await rep.getUserFavourites(userId: user.id);
});
