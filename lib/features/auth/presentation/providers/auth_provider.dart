import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/features/auth/data/models/user_model.dart';
import 'package:travelcompanion/features/auth/data/repositories/auth_repository.dart';
import 'package:travelcompanion/features/auth/data/repositories/user_repository.dart';
import 'package:travelcompanion/features/auth/data/services/auth_service.dart';
import 'auth_state.dart';
import 'package:flutter/material.dart';

final _authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository();
});

final _userRepositoryProvider = Provider<UserRepository>((ref) {
  return SupabaseUserRepository();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final authRepository = ref.watch(_authRepositoryProvider);
  final userRepository = ref.watch(_userRepositoryProvider);
  return AuthService(authRepository, userRepository);
});
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return null;

  final response = await Supabase.instance.client
      .from('users')
      .select()
      .eq('id', session.user.id)
      .maybeSingle();

  if (response == null) return null;
  return UserModel.fromJson(response);
});

final authStateProvider = StreamProvider<AuthNotifierState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((event) {
    return AuthNotifierState(
      isLoading: false,
      user: event.session != null
          ? UserModel(
              id: event.session!.user.id,
              email: event.session!.user.email ?? '',
              createdAt: DateTime.now(),
            )
          : null,
    );
  });
});

class AuthNotifier extends StateNotifier<AuthNotifierState> {
  final AuthService _authService;
  final ImagePicker _picker = ImagePicker();

  AuthNotifier(this._authService) : super(AuthNotifierState()) {
    getCurrentUser();
  }
  Future<bool> signIn(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await _authService.signIn(email, password);

      if (user == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      final currentUser = await _authService.getCurrentUser();

      state = state.copyWith(isLoading: false, user: currentUser);
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

  Future<void> getCurrentUser() async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await _authService.getCurrentUser();

      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? country,
    String? avatarUrl,
    TextEditingController? nameController,
    TextEditingController? countryController,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      final updatedUser = await _authService.updateUserProfile(
        userId: userId,
        name: name,
        country: country,
        avatarUrl: avatarUrl,
      );
      state = state.copyWith(isLoading: false, user: updatedUser);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> pickAndUploadPhoto() async {
    try {
      state = state.copyWith(isLoading: true);

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final photoUrl = await _authService.uploadPhoto(image.path);

      if (photoUrl != null) {
        final updatedUser = await _authService.updateUserProfile(
          userId: state.user!.id,
          avatarUrl: photoUrl,
        );
        state = state.copyWith(isLoading: false, user: updatedUser);
      }
    } catch (e) {
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthNotifierState>((
  ref,
) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
