
import 'package:travelcompanion/features/auth/data/models/user_model.dart';

class AuthNotifierState {
  final bool isLoading;
  final UserModel? user;

  AuthNotifierState({this.isLoading = false, this.user});

  AuthNotifierState copyWith({
    bool? isLoading,
    UserModel? user,
  }) {
    return AuthNotifierState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
    );
  }
}
