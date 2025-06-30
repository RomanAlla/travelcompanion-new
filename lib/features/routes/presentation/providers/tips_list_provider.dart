import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/routes/data/models/tip_model.dart';
import 'package:travelcompanion/features/routes/presentation/providers/tip_repository_provider.dart';

final tipsListProvider = FutureProvider.family<List<TipModel>, String>((
  ref,
  routeId,
) async {
  return await ref.watch(tipRepositoryProvider).getTips(routeId: routeId);
});
