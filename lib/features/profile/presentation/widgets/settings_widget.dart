import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/presentation/router/router.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/tile_widget.dart';

class SettingsWidget extends ConsumerWidget {
  const SettingsWidget({super.key});

  Future<void> logOut(WidgetRef ref, BuildContext context) async {
    await ref.read(authProvider.notifier).signOut();
    if (!context.mounted) return;
    ref.invalidate(authProvider);
    context.router.pushAndPopUntil(SignInRoute(), predicate: (route) => false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLightColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  color: AppTheme.primaryLightColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Настройки',
                style: AppTheme.titleSmallBold.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
        TileWidget(
          title: 'Уведомления',
          width: 40,
            icon: Icons.notifications_active_rounded,
        ),
          const SizedBox(height: 10),
          TileWidget(
            title: 'Конфиденциальность',
            width: 40,
            icon: Icons.shield_rounded,
          ),
          const SizedBox(height: 10),
          TileWidget(
            title: 'Тема',
            width: 40,
            icon: Icons.dark_mode_rounded,
          ),
          const SizedBox(height: 10),
        TileWidget(
          title: 'Выход',
          width: 40,
            icon: Icons.logout_rounded,
          onTap: () => logOut(ref, context),
            isDestructive: true,
        ),
      ],
      ),
    );
  }
}
