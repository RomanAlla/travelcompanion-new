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
final authProvider = StateNotifierProvider<AuthNotifier, AuthNotifierState>((
  ref,
) {
  final authService = ref.watch(authServiceProvider);
  final userService = ref.watch(userServiceProvider);
  return AuthNotifier(authService, userService)..initialize();
});

final appInitializationProvider = FutureProvider<void>((ref) async {
  await Future.delayed(const Duration(seconds: 2));

  bool isLoading = true;
  while (isLoading) {
    final state = ref.read(authProvider);
    isLoading = state.isLoading;

    if (isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
});

final isAppInitializedProvider = Provider<bool>((ref) {
  final initializationState = ref.watch(appInitializationProvider);
  return !initializationState.isLoading && !initializationState.hasError;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider.select((state) => state.user));
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider.select((state) => state.isLoading));
});
