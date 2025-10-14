import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelcompanion/features/auth/data/services/user_service.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/auth/presentation/providers/profile_state.dart';

class UserNotifier extends StateNotifier<UserState> {
  final UserService _userService;
  final Ref _ref;

  UserNotifier(this._userService, this._ref) : super(UserState()) {
    _syncWithAuthState();
    getCurrentUser();
  }
  void _syncWithAuthState() {
    _ref.listen(authProvider, (previous, next) {
      if (next.user != null && state.user?.id != next.user?.id) {
        state = state.copyWith(user: next.user);
      } else if (next.user == null && state.user != null) {
        state = state.copyWith(user: null);
      }
    });
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? phoneNumber,
    String? email,
    String? country,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      final updatedUser = await _userService.updateUser(
        userId: userId,
        name: name,
        phoneNumber: phoneNumber,
        email: email,
        country: country,
      );
      state = state.copyWith(isLoading: false, user: updatedUser);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> pickAndUploadPhoto(XFile? image) async {
    state = state.copyWith(isLoading: true);

    if (image == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      await _userService.uploadUserPhoto(image.path);
      final refreshedUser = await _userService.getCurrentUser();
      state = state.copyWith(user: refreshedUser);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> getCurrentUser() async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await _userService.getCurrentUser();

      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}
