import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/route_builder/data/models/route_model.dart';
import 'package:travelcompanion/features/route_builder/data/repository/route_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final searchRoutesProvider = FutureProvider.family<List<RouteModel>, String?>((
  ref,
  query,
) async {
  final repository = RouteRepository();
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    throw 'Пользователь не авторизован';
  }

  return repository.searchRoutes(query: query, userId: user.id);
});
