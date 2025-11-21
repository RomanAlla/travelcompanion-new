import 'package:flutter/material.dart';
import 'package:travelcompanion/core/presentation/widgets/app_bar.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/features/moderation/presentation/screens/admin_routes_screen.dart';
import 'package:travelcompanion/features/moderation/presentation/screens/admin_comments_screen.dart';
import 'package:travelcompanion/features/moderation/presentation/screens/admin_users_screen.dart';

class AdminHubScreen extends StatelessWidget {
  const AdminHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: const AppBarWidget(title: 'Админ панель'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AdminTile(
                icon: Icons.map_outlined,
                title: 'Маршруты (все)',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminRoutesScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _AdminTile(
                icon: Icons.chat_bubble_outline,
                title: 'Комментарии (все)',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminCommentsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _AdminTile(
                icon: Icons.people_outline,
                title: 'Пользователи',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _AdminTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.lightBlue,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryLightColor),
            const SizedBox(width: 12),
            Text(title, style: AppTheme.bodyLarge),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
