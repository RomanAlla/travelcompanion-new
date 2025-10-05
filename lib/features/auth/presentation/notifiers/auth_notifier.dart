import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/features/auth/data/services/auth_service.dart';
import 'package:travelcompanion/features/auth/data/services/user_service.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthNotifierState> {
  final AuthService _authService;
  final UserService _userService;

  AuthNotifier(this._authService, this._userService)
    : super(AuthNotifierState());

  Future<void> initialize() async {
    try {
      state = state.copyWith(isLoading: true);

      // Проверяем текущую сессию в Supabase
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        // Если есть сессия, загружаем данные пользователя
        final user = await _userService.getCurrentUser();
        state = state.copyWith(isLoading: false, user: user);
      } else {
        // Если сессии нет, просто завершаем загрузку
        state = state.copyWith(isLoading: false, user: null);
      }
    } catch (e) {
      print('Error initializing auth: $e');
      state = state.copyWith(isLoading: false, user: null);
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await _authService.signIn(email, password);

      if (user == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await _authService.signUp(
        email: email,
        password: password,
        name: email.split('@')[0],
      );

      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);
      await _authService.signOut();

      state = state.copyWith(isLoading: false, user: null);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}
