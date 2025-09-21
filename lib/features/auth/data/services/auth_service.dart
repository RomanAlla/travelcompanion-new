import 'dart:io';

import 'package:travelcompanion/core/error/app_exception.dart';
import 'package:travelcompanion/features/auth/data/models/user_model.dart';
import 'package:travelcompanion/features/auth/data/repositories/auth_repository.dart';
import 'package:travelcompanion/features/auth/data/repositories/user_repository.dart';

class AuthService {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthService(this._authRepository, this._userRepository);

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final authResponse = await _authRepository.signUp(email, password);

      if (authResponse.user == null) {
        throw AppException('Ошибка при регистрации пользователя');
      }

      final user = UserModel(
        id: authResponse.user!.id,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      try {
        final userResponse = await _userRepository.updateUser(user);
        return userResponse;
      } catch (e) {
        throw AppException('Ошибка при создании профиля пользователя: $e');
      }
    } catch (e) {
      throw AppException('$e');
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final authResponse = await _authRepository.signIn(email, password);

      if (authResponse.user == null) {
        throw AppException('Ошибка при входе');
      }

      try {
        final user = await _userRepository.getCurrentUser();
        if (user != null) {
          return user;
        }

        final newUser = UserModel(
          id: authResponse.user!.id,
          email: authResponse.user!.email!,
          createdAt: DateTime.now(),
        );

        final userResponse = await _userRepository.updateUser(newUser);

        return userResponse;
      } catch (e) {
        throw AppException('Ошибка при получении профиля пользователя: $e');
      }
    } catch (e) {
      throw AppException('Ошибка входа: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      throw AppException('Ошибка при выходе: $e');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = await _userRepository.getCurrentUser();

      return user;
    } catch (e) {
      throw AppException('Ошибка получения пользователя: $e');
    }
  }

  Future<UserModel?> updateUserProfile({
    required String userId,
    String? name,
    String? country,
    String? avatarUrl,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) {
        throw AppException('Пользователь не найден');
      }

      final updatedUser = UserModel(
        id: currentUser.id,
        email: currentUser.email,
        phoneNumber: phoneNumber ?? currentUser.phoneNumber,
        name: name ?? currentUser.name,
        country: country ?? currentUser.country,
        createdAt: currentUser.createdAt,
        avatarUrl: avatarUrl ?? currentUser.avatarUrl,
      );

      final userResponse = await _userRepository.updateUser(updatedUser);

      return userResponse;
    } catch (e) {
      throw AppException('Ошибка обновления профиля: $e');
    }
  }

  Future<String?> uploadPhoto(String filePath) async {
    try {
      final file = File(filePath);
      return await _userRepository.uploadPhoto(file);
    } catch (e) {
      throw AppException('Ошибка загрузки фото: $e');
    }
  }
}
