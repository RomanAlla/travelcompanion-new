import 'package:travelcompanion/core/domain/entities/user_model.dart';

class AuthNotifierState {
  final bool isLoading;
  final UserModel? user;
  final bool isAuthenticated;

  AuthNotifierState({
    this.isLoading = false,
    this.user,
    this.isAuthenticated = false,
  });

  AuthNotifierState.initial()
    : isLoading = false,
      user = null,
      isAuthenticated = false;

  AuthNotifierState.authenticated(UserModel user)
    : isLoading = false,
      user = user,
      isAuthenticated = true;

  AuthNotifierState.unauthenticated()
    : isLoading = false,
      user = null,
      isAuthenticated = false;

  AuthNotifierState copyWith({
    bool? isLoading,
    UserModel? user,
    bool? isAuthenticated,
  }) {
    return AuthNotifierState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}
