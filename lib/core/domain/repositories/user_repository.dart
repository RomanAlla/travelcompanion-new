import 'dart:io';

import 'package:travelcompanion/core/domain/entities/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getCurrentUser();

  Future<UserModel?> updateUser(UserModel user);

  Future<String?> uploadUserPhoto(File file);

  Future<UserModel?> getUserById(String id);
}
