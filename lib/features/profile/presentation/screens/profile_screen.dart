import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/router/router.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/core/widgets/app_bar.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/avatar_widget.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/settings_widget.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/trips_column_widget.dart';

@RoutePage()
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: Colors.white,

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 50,
            flexibleSpace: AppBarWidget(title: 'Настройки'),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30),
                    AvatarWidget(),
                    SizedBox(height: 5),
                    Text(user!.name ?? user.email, style: AppTheme.titleLarge),
                    Text(
                      'Создан в ${user.createdAt.year.toString()}',
                      style: AppTheme.hintStyle,
                    ),
                    SizedBox(height: 7),
                    ElevatedButton(
                      onPressed: () {
                        context.router.push(EditProfileRoute());
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightGrey,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
                    TripsColumnWidget(),
                    SizedBox(height: 15),

                    SettingsWidget(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // body: SingleChildScrollView(
      //   child: Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 15),
      //     child: Center(
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         children: [
      //           SizedBox(height: 30),
      //           CircleAvatar(
      //             radius: 65,
      //             backgroundImage: user!.avatarUrl != null
      //                 ? NetworkImage(user.avatarUrl!)
      //                 : null,
      //             child: user.avatarUrl == null
      //                 ? Icon(Icons.add_a_photo)
      //                 : null,
      //           ),
      //           SizedBox(height: 5),
      //           Text(user.name ?? user.email, style: AppTheme.titleLarge),
      //           Text(
      //             'Создан в ${user.createdAt.year.toString()}',
      //             style: AppTheme.hintStyle,
      //           ),
      //           SizedBox(height: 7),
      //           ElevatedButton(
      //             onPressed: () {},

      //             style: ElevatedButton.styleFrom(
      //               backgroundColor: AppTheme.lightGrey,
      //               elevation: 0,
      //               padding: const EdgeInsets.symmetric(vertical: 10),
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(10),
      //               ),
      //             ),
      //             child: Center(
      //               child: Text(
      //                 'Редактировать профиль',
      //                 style: AppTheme.bodyMediumBold,
      //               ),
      //             ),
      //           ),
      //           SizedBox(height: 20),
      //           TripsColumnWidget(),
      //           SizedBox(height: 15),

      //           SettingsWidget(),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
