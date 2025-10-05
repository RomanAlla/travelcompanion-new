import 'package:travelcompanion/core/domain/exceptions/app_exception.dart';
import 'package:travelcompanion/core/domain/entities/user_model.dart';
import 'package:travelcompanion/core/domain/repositories/auth_repository.dart';
import 'package:travelcompanion/core/domain/repositories/user_repository.dart';

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

      final user = await _userRepository.getUserById(authResponse.user!.id);

      if (user == null) {
        throw AppException('Ошибка при регистрации пользователя');
      }
      return user;
    } catch (e) {
      throw AppException('$e');
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final authResponse = await _authRepository.signIn(email, password);

      final user = await _userRepository.getUserById(authResponse.user!.id);
      if (user == null) {
        throw AppException('Профиль пользователя не найден');
      }

      return user;
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
}
