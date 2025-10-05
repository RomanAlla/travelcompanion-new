import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/repositories/user_repository.dart';
import 'package:travelcompanion/features/auth/data/repositories/user_repository_impl.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl();
});
