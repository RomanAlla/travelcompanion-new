import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/presentation/router/router.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/core/presentation/widgets/app_bar.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/profile/presentation/providers/planned_routes_count_provider.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/avatar_widget.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/settings_widget.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/trips_column_widget.dart';

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
    final routesStats = ref.watch(plannedRoutesCountProvider(user!.id));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 60),
        child: AppBarWidget(title: 'Профиль'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name ?? user.email, style: AppTheme.titleLarge),
                      Text(
                        user.email,
                        style: AppTheme.bodyMediumBold.copyWith(
                          color: AppTheme.primaryLightColor,
                        ),
                      ),
                    ],
                  ),

                  Stack(
                    children: [
                      AvatarWidget(radius: 40, avatarUrl: user.avatarUrl),
                      Positioned(
                        right: 2,
                        top: 3,
                        child: SizedBox(
                          height: 25,
                          width: 25,
                          child: Center(
                            child: IconButton(
                              padding: EdgeInsets.all(2),

                              style: IconButton.styleFrom(
                                shape: CircleBorder(),
                                backgroundColor: AppTheme.primaryLightColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                context.router.push(EditProfileRoute());
                              },
                              icon: Icon(Icons.edit, size: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Text(
                'Создан в ${user.createdAt.year.toString()}',
                style: AppTheme.hintStyle,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  context.router.push(EditProfileRoute());
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightGrey,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Редактировать профиль',
                    style: AppTheme.bodyMediumBold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              routesStats.when(
                data: (stats) => TripsColumnWidget(plannedCount: stats),
                error: (error, stack) => TripsColumnWidget(plannedCount: 0),
                loading: () => TripsColumnWidget(plannedCount: 0),
              ),
              SizedBox(height: 15),

              SettingsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
