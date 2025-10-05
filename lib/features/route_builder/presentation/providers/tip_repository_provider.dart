import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/data/repositories/tip_repository_impl.dart';
import 'package:travelcompanion/core/domain/repositories/tip_repository.dart';

final tipRepositoryProvider = Provider<TipRepository>((ref) {
  return TipRepositoryImpl();
});
