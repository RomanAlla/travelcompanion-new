import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/core/domain/exceptions/app_exception.dart';
import 'package:travelcompanion/core/domain/entities/user_model.dart';
import 'package:travelcompanion/core/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'user-photos';

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return null;
      }

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      final userModel = UserModel.fromJson(response);

      return userModel;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel?> updateUser(UserModel user) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw AppException('Пользователь не авторизован');
      }

      final userData = UserModel(
        id: user.id,
        email: user.email,
        avatarUrl: user.avatarUrl,
        phoneNumber: user.phoneNumber,
        country: user.country,
        name: user.name,
        createdAt: DateTime.now(),
      );

      final response = await _supabase
          .from('users')
          .upsert(userData, onConflict: 'id')
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw AppException('Ошибка обновления пользователя: $e');
    }
  }

  @override
  Future<String?> uploadUserPhoto(File file) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AppException('Пользователь не авторизован');
      }

      final fileName =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage.from(_bucketName).upload(fileName, file);

      final photoUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(fileName);

      await _supabase
          .from('users')
          .update({'avatar_url': photoUrl})
          .eq('id', user.id);

      return photoUrl;
    } catch (e) {
      throw AppException('Ошибка загрузки фото: $e');
    }
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }
      final user = UserModel.fromJson(response);

      return user;
    } catch (e) {
      throw AppException('Ошибка обновления пользователя: $e');
    }
  }

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _supabase.from('users').select();
      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw AppException('Ошибка получения пользователей: $e');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _supabase.from('users').delete().eq('id', id);
    } catch (e) {
      throw AppException('Ошибка удаления пользователя: $e');
    }
  }
}
