import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/route_builder/data/repository/tip_repository.dart';

final tipRepositoryProvider = Provider<TipRepository>((ref) {
  return TipRepository();
});
