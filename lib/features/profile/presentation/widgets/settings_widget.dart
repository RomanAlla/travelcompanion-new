import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/router/router.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/tile_widget.dart';

class SettingsWidget extends ConsumerWidget {
  const SettingsWidget({super.key});

  Future<void> logOut(WidgetRef ref, BuildContext context) async {
    await ref.read(authServiceProvider).signOut();
    if (!context.mounted) return;
    context.router.pushAndPopUntil(SignInRoute(), predicate: (route) => false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Настройки', style: AppTheme.titleSmallBold),
        SizedBox(height: 8),
        TileWidget(
          title: 'Уведомления',
          width: 40,
          icon: Icons.notification_add,
        ),
        SizedBox(height: 10),
        TileWidget(title: 'Конфиденциальнсоть', width: 40, icon: Icons.shield),
        SizedBox(height: 10),
        TileWidget(title: 'Тема', width: 40, icon: Icons.dark_mode),
        SizedBox(height: 10),
        TileWidget(
          title: 'Выход',
          width: 40,
          icon: Icons.logout,
          onTap: () => logOut(ref, context),
        ),
      ],
    );
  }
}
