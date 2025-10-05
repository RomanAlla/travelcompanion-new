import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/entities/tip_model.dart';
import 'package:travelcompanion/core/presentation/providers/use_cases_providers.dart';

final tipsListProvider = FutureProvider.family<List<TipModel>, String>((
  ref,
  routeId,
) async {
  return await ref.watch(tipRepositoryProvider).getTips(routeId: routeId);
});
