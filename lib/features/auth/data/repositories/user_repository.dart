import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/features/auth/data/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel?> updateUser(UserModel user);
  Future<void> signOut();
  Future<String?> uploadPhoto(File file);
}

class SupabaseUserRepository implements UserRepository {
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
        throw 'Пользователь не авторизован';
      }

      final userData = UserModel(
        id: user.id,
        email: user.email,
        avatarUrl: user.avatarUrl,

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
      print('Error updating user: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String?> uploadPhoto(File file) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return null;
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
      rethrow;
    }
  }
}
