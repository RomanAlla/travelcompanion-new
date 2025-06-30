import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/routes/data/repository/tip_repository.dart';

final tipRepositoryProvider = Provider<TipRepository>((ref) {
  return TipRepository();
});
