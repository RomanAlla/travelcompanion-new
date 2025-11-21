import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/presentation/router/router.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/profile/presentation/providers/planned_routes_count_provider.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/avatar_widget.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/settings_widget.dart';

@RoutePage()
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    // Если пользователь не авторизован, показываем пустой экран или редирект
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final routesStats = ref.watch(plannedRoutesCountProvider(user.id));

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(color: AppTheme.primaryLightColor),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Профиль',
                          style: AppTheme.titleLarge.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Карточка профиля
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
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
                    children: [
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryLightColor.withValues(
                                  alpha: 0.3,
                                ),
                                width: 2,
                              ),
                            ),
                            child: AvatarWidget(
                              radius: 40,
                              avatarUrl: user.avatarUrl,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLightColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryLightColor
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    context.router.push(EditProfileRoute());
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name ?? user.email,
                        style: AppTheme.titleSmallBold.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLightColor.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          user.email,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryLightColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Создан в ${user.createdAt.year}',
                              style: AppTheme.bodyMini.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Кнопка редактирования
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLightColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryLightColor.withValues(
                            alpha: 0.2,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          context.router.push(EditProfileRoute());
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Редактировать профиль',
                                style: AppTheme.bodySmallBold.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Статистика
                routesStats.when(
                  data: (stats) => _buildStatsSection(stats),
                  error: (error, _) => _buildStatsSection(0),
                  loading: () => _buildStatsSection(0),
                ),
                const SizedBox(height: 20),
                // Настройки
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SettingsWidget(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(int plannedCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
                  Icons.analytics_rounded,
                  color: AppTheme.primaryLightColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Статистика',
                style: AppTheme.titleSmallBold.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.route_rounded,
                  value: '$plannedCount',
                  label: 'Запланировано',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.favorite_rounded,
                  value: '0',
                  label: 'Избранных',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryLightColor, size: 22),
          const SizedBox(height: 6),
          Text(value, style: AppTheme.titleSmallBold.copyWith(fontSize: 20)),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTheme.bodyMini.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
