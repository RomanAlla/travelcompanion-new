import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/presentation/widgets/app_bar.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/features/moderation/presentation/providers/admin_users_provider.dart';
import 'package:travelcompanion/core/presentation/providers/user_repo_provider.dart';

enum UserRole { user, moderator, admin }

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'Пользователь';
      case UserRole.moderator:
        return 'Модератор';
      case UserRole.admin:
        return 'Администратор';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.user:
        return Colors.blue;
      case UserRole.moderator:
        return Colors.orange;
      case UserRole.admin:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.user:
        return Icons.person;
      case UserRole.moderator:
        return Icons.security;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }
}

class ModeratorUsersScreen extends ConsumerWidget {
  const ModeratorUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBarWidget(title: 'Пользователи'),
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            const Center(child: Text('Произошла ошибка... Попробуйте позже')),
        data: (users) {
          if (users.isEmpty) return const Center(child: Text('Пусто'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              final role = UserRole.values[index % 3];
              return _ModeratorUserCard(
                user: user,
                role: role,
                onDelete: () async {
                  final repo = ref.read(userRepositoryProvider);
                  await repo.deleteUser(user.id);
                  ref.invalidate(adminUsersProvider);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.white,
                      content: Center(
                        child: Text(
                          style: AppTheme.bodyMediumBold.copyWith(
                            color: AppTheme.primaryLightColor,
                          ),
                          'Пользователь удален',
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ModeratorUserCard extends StatelessWidget {
  final dynamic user;
  final UserRole role;
  final VoidCallback onDelete;

  const _ModeratorUserCard({
    required this.user,
    required this.role,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 28,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name ?? 'Без имени',
                      style: AppTheme.bodyMediumBold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.grey600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                tooltip: 'Удалить',
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(role.icon, size: 18, color: role.color),
              const SizedBox(width: 8),
              Text(
                'Роль:',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.grey600),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: role.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: role.color, width: 1.5),
                ),
                child: Text(
                  role.displayName,
                  style: AppTheme.bodySmallBold.copyWith(color: role.color),
                ),
              ),
              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Только просмотр',
                      style: AppTheme.bodyMini.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
