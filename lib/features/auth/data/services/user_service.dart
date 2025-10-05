import 'dart:io';

import 'package:travelcompanion/core/domain/entities/user_model.dart';
import 'package:travelcompanion/core/domain/exceptions/app_exception.dart';
import 'package:travelcompanion/core/domain/repositories/user_repository.dart';

class UserService {
  final UserRepository _userRepository;

  UserService(this._userRepository);

  Future<UserModel?> updateUser({
    required String userId,
    String? name,
    String? country,
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
      );

      final userResponse = await _userRepository.updateUser(updatedUser);

      return userResponse;
    } catch (e) {
      throw AppException('Ошибка обновления профиля: $e');
    }
  }

  Future<String?> uploadUserPhoto(String filePath) async {
    try {
      final file = File(filePath);
      return await _userRepository.uploadUserPhoto(file);
    } catch (e) {
      throw AppException('Ошибка загрузки фото: $e');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _userRepository.getCurrentUser();
    return user;
  }
}
