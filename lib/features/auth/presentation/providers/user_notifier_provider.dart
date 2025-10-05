import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/auth/presentation/notifiers/user_notifier.dart';
import 'package:travelcompanion/features/auth/presentation/providers/profile_state.dart';
import 'package:travelcompanion/features/auth/presentation/providers/user_service.dart';

final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>((
  ref,
) {
  final userService = ref.watch(userServiceProvider);
  return UserNotifier(userService);
});
