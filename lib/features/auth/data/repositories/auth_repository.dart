import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<AuthResponse> signUp(String email, String password);
  Future<AuthResponse> signIn(String email, String password);
  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw 'Ошибка при создании пользователя';
      }

      return response;
    } on AuthException catch (e) {
      switch (e.message) {
        case 'User already registered':
          throw 'Email уже используется';
        case 'Invalid email':
          throw 'Некорректный email';
        case 'Password should be at least 6 characters':
          throw 'Пароль должен содержать минимум 6 символов';
        default:
          throw 'Ошибка регистрации: ${e.message}';
      }
    } catch (e) {
      throw 'Неизвестная ошибка при регистрации: $e';
    }
  }

  @override
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw 'Ошибка при входе';
      }

      return response;
    } on AuthException catch (e) {
      switch (e.message) {
        case 'Invalid login credentials':
          throw 'Неверный email или пароль';
        case 'Email not confirmed':
          throw 'Email не подтвержден';
        case 'User not found':
          throw 'Пользователь не найден';
        default:
          throw 'Ошибка входа: ${e.message}';
      }
    } catch (e) {
      throw 'Неизвестная ошибка при входе: $e';
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw 'Ошибка при выходе: $e';
    }
  }
}
