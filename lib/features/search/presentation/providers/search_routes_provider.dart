import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/core/presentation/providers/use_cases_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final searchRoutesProvider = FutureProvider.family<List<RouteModel>, String?>((
  ref,
  query,
) async {
  final useCase = ref.watch(searchRoutesUseCaseProvider);
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    throw 'Пользователь не авторизован';
  }

  return await useCase.call(query: query, userId: user.id);
});
