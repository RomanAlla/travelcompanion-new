import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/presentation/widgets/app_bar.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/features/moderation/presentation/providers/admin_users_provider.dart';
import 'package:travelcompanion/core/presentation/providers/user_repo_provider.dart';

// Простая модель роли для UI
enum UserRole { user, moderator, admin }

// Расширение для красивого отображения
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

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBarWidget(title: 'Управление пользователями'),
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
              // Временная логика для демонстрации - случайная роль
              final role = UserRole.values[index % 3];
              return _UserCard(
                user: user,
                currentRole: role,
                onRoleChanged: (newRole) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.white,
                      content: Center(
                        child: Text(
                          style: AppTheme.bodyMediumBold.copyWith(
                            color: AppTheme.primaryLightColor,
                          ),
                          'Роль "${newRole.displayName}" назначена ${user.name ?? user.email}',
                        ),
                      ),
                    ),
                  );
                },
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

class _UserCard extends StatefulWidget {
  final dynamic user;
  final UserRole currentRole;
  final Function(UserRole) onRoleChanged;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.currentRole,
    required this.onRoleChanged,
    required this.onDelete,
  });

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.currentRole;
  }

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
          // Информация о пользователе
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 28,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name ?? 'Без имени',
                      style: AppTheme.bodyMediumBold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.email,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.grey600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                tooltip: 'Удалить',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Текущая роль
          Row(
            children: [
              Icon(_selectedRole.icon, size: 20, color: _selectedRole.color),
              const SizedBox(width: 8),
              Text(
                'Текущая роль:',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.grey600),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _selectedRole.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _selectedRole.color, width: 1.5),
                ),
                child: Text(
                  _selectedRole.displayName,
                  style: AppTheme.bodySmallBold.copyWith(
                    color: _selectedRole.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Селектор роли
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<UserRole>(
                value: _selectedRole,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem<UserRole>(
                    value: role,
                    child: Row(
                      children: [
                        Icon(role.icon, size: 20, color: role.color),
                        const SizedBox(width: 8),
                        Text(
                          role.displayName,
                          style: AppTheme.bodyMedium.copyWith(
                            color: role.color,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newRole) {
                  if (newRole != null) {
                    setState(() {
                      _selectedRole = newRole;
                    });
                    widget.onRoleChanged(newRole);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
