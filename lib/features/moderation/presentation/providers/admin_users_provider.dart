import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/entities/user_model.dart';
import 'package:travelcompanion/core/presentation/providers/user_repo_provider.dart';

final adminUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return await repo.getUsers();
});


