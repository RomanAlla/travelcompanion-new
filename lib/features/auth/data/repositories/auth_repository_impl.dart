import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/core/domain/exceptions/app_exception.dart';
import 'package:travelcompanion/core/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AppException('Ошибка при создании пользователя');
      }

      return response;
    } on AuthException catch (e) {
      switch (e.message) {
        case 'User already registered':
          throw AppException('Email уже используется');
        case 'Invalid email':
          throw AppException('Некорректный email');
        case 'Password should be at least 6 characters':
          throw AppException('Пароль должен содержать минимум 6 символов');
        default:
          throw AppException('Ошибка регистрации:  ${e.message}');
      }
    } catch (e) {
      throw AppException('Неизвестная ошибка при регистрации: $e');
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
        throw AppException('Ошибка при входе');
      }

      return response;
    } on AuthException catch (e) {
      switch (e.message) {
        case 'Invalid login credentials':
          throw AppException('Неверный email или пароль');
        case 'Email not confirmed':
          throw AppException('Email не подтвержден');
        case 'User not found':
          throw AppException('Пользователь не найден');
        default:
          throw AppException('Ошибка входа: ${e.message}');
      }
    } catch (e) {
      throw AppException('Неизвестная ошибка при входе: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AppException('Ошибка при выходе: $e');
    }
  }
}
