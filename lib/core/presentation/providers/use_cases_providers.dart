import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/usecases/create_comment_use_case.dart';
import 'package:travelcompanion/core/domain/usecases/get_route_details_use_case.dart';
import 'package:travelcompanion/core/domain/usecases/remove_from_favourites_use_case.dart';
import 'package:travelcompanion/core/data/repositories/route_repository_impl.dart';
import 'package:travelcompanion/core/data/repositories/comment_repository_impl.dart';
import 'package:travelcompanion/core/data/repositories/tip_repository_impl.dart';
import 'package:travelcompanion/core/domain/usecases/search_routes_use_case.dart';
import 'package:travelcompanion/features/favourite/data/repository/favourite_repository_impl.dart';

final routeRepositoryProvider = Provider((ref) {
  return RouteRepositoryImpl();
});
final addToFavouritesUseCaseProvider = Provider<AddToFavouritesUseCase>((ref) {
  final favouriteRepository = ref.watch(favouriteRepositoryProvider);
  return AddToFavouritesUseCase(favouriteRepository);
});

final commentRepositoryProvider = Provider((ref) {
  return CommentRepositoryImpl();
});

final favouriteRepositoryProvider = Provider((ref) {
  return FavouriteRepositoryImpl();
});

final tipRepositoryProvider = Provider((ref) {
  return TipRepositoryImpl();
});

final getRouteDetailsUseCaseProvider = Provider<GetRouteDetailsUseCase>((ref) {
  final routeRepository = ref.watch(routeRepositoryProvider);
  final commentRepository = ref.watch(commentRepositoryProvider);
  return GetRouteDetailsUseCase(routeRepository, commentRepository);
});

final removeFromFavouritesUseCaseProvider = Provider<AddToFavouritesUseCase>((
  ref,
) {
  final favouriteRepository = ref.watch(favouriteRepositoryProvider);
  return AddToFavouritesUseCase(favouriteRepository);
});

final searchRoutesUseCaseProvider = Provider<SearchRoutesUseCase>((ref) {
  final routeRepository = ref.watch(routeRepositoryProvider);
  return SearchRoutesUseCase(routeRepository);
});

final createCommentUseCaseProvider = Provider<CreateCommentUseCase>((ref) {
  final commentRepository = ref.watch(commentRepositoryProvider);
  return CreateCommentUseCase(commentRepository);
});
