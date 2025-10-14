import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/entities/user_model.dart';
import 'package:travelcompanion/core/presentation/providers/auth_repo_provider.dart';
import 'package:travelcompanion/features/auth/data/services/auth_service.dart';
import 'package:travelcompanion/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:travelcompanion/features/auth/presentation/providers/user_repository.dart';
import 'package:travelcompanion/features/auth/presentation/providers/user_service.dart';
import 'auth_state.dart';

// Сервис провайдер
final authServiceProvider = Provider<AuthService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthService(authRepository, userRepository);
});

// Главный провайдер состояния аутентификации
final authProvider =
    StateNotifierProvider.autoDispose<AuthNotifier, AuthNotifierState>((ref) {
      final authService = ref.watch(authServiceProvider);
      final userService = ref.watch(userServiceProvider);
      return AuthNotifier(authService, userService)..initialize();
    });

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider.select((state) => state.user));
});
