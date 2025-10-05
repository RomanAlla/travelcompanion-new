import 'package:travelcompanion/core/domain/entities/user_model.dart';

class UserState {
  final bool isLoading;
  final UserModel? user;

  UserState({this.isLoading = false, this.user});

  UserState copyWith({bool? isLoading, UserModel? user}) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
    );
  }
}
