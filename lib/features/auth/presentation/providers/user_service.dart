import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/auth/data/services/user_service.dart';
import 'package:travelcompanion/features/auth/presentation/providers/user_repository.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserService(userRepository);
});
