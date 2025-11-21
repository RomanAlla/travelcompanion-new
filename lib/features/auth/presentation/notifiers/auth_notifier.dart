import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/core/domain/entities/user_model.dart';
import 'package:travelcompanion/features/auth/data/services/auth_service.dart';
import 'package:travelcompanion/features/auth/data/services/user_service.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthNotifierState> {
  final AuthService _authService;
  final UserService _userService;
  bool _disposed = false;

  AuthNotifier(this._authService, this._userService)
    : super(AuthNotifierState(isLoading: true));

  /// Безопасное обновление состояния с проверкой на dispose
  void _safeSetState(AuthNotifierState newState) {
    if (!_disposed) {
      try {
        state = newState;
      } catch (e) {
        // Игнорируем ошибки, если notifier уже удален
        if (e is! StateError || !e.message.contains('dispose')) {
          rethrow;
        }
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> initialize() async {
    try {
      // isLoading уже true при создании, но на всякий случай устанавливаем явно
      if (!_disposed && !state.isLoading) {
        _safeSetState(state.copyWith(isLoading: true));
      }

      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        final user = await _userService.getCurrentUser();
        if (!_disposed) {
          _safeSetState(state.copyWith(isLoading: false, user: user));
        }
      } else {
        if (!_disposed) {
          _safeSetState(state.copyWith(isLoading: false, user: null));
        }
      }
    } catch (e) {
      if (!_disposed) {
        _safeSetState(state.copyWith(isLoading: false, user: null));
      }
      // Не пробрасываем ошибку, если notifier уже удален
      if (_disposed) {
        return;
      }
      rethrow;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      if (_disposed) return false;
      _safeSetState(state.copyWith(isLoading: true));
      final user = await _authService.signIn(email, password);

      if (_disposed) return false;

      if (user == null) {
        _safeSetState(state.copyWith(isLoading: false));
        return false;
      }

      _safeSetState(state.copyWith(isLoading: false, user: user));
      return true;
    } catch (e) {
      if (!_disposed) {
        _safeSetState(state.copyWith(isLoading: false));
      }
      if (_disposed) {
        return false;
      }
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      if (_disposed) return;
      _safeSetState(state.copyWith(isLoading: true));
      final user = await _authService.signUp(
        email: email,
        password: password,
        name: email.split('@')[0],
      );

      if (!_disposed) {
        _safeSetState(state.copyWith(isLoading: false, user: user));
      }
    } catch (e) {
      if (!_disposed) {
        _safeSetState(state.copyWith(isLoading: false));
      }
      if (_disposed) {
        return;
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      if (_disposed) return;
      _safeSetState(state.copyWith(isLoading: true));
      await _authService.signOut();

      if (!_disposed) {
        _safeSetState(state.copyWith(isLoading: false, user: null));
      }
    } catch (e) {
      if (!_disposed) {
        _safeSetState(state.copyWith(isLoading: false));
      }
      if (_disposed) {
        return;
      }
      rethrow;
    }
  }

  void updateUser(UserModel user) {
    if (!_disposed && state.user?.id == user.id) {
      _safeSetState(state.copyWith(user: user));
    }
  }
}
