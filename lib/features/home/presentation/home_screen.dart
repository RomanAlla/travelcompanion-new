import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:travelcompanion/features/auth/presentation/providers/user_notifier_provider.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/features/main/presentation/screens/main_routes_screen.dart';
import 'package:travelcompanion/features/favourite/presentation/screens/favourite_screen.dart';
import 'package:travelcompanion/features/travels/presentation/screens/travels_screen.dart';
import 'package:travelcompanion/features/profile/presentation/screens/profile_screen.dart';

@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      const MainRoutesScreen(),
      const FavouriteScreen(),
      const ProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.search_rounded),
        title: "Поиск",
        textStyle: AppTheme.bodySmallBold,
        activeColorPrimary: Colors.lightBlueAccent.withOpacity(0.3),
        inactiveColorPrimary: Colors.grey.shade600,
        activeColorSecondary: AppTheme.primaryLightColor,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.favorite_border_rounded),
        title: "Избранное",
        activeColorPrimary: Colors.lightBlueAccent.withOpacity(0.3),
        inactiveColorPrimary: Colors.grey.shade600,
        activeColorSecondary: AppTheme.primaryLightColor,
      ),

      PersistentBottomNavBarItem(
        activeColorSecondary: AppTheme.primaryLightColor,
        icon: const Icon(Icons.person_rounded),
        title: "Профиль",
        activeColorPrimary: Colors.lightBlueAccent.withOpacity(0.3),
        inactiveColorPrimary: Colors.grey.shade600,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(userNotifierProvider);

    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.once,
      backgroundColor: Colors.white,
      navBarHeight: kBottomNavigationBarHeight + 8,
      navBarStyle: NavBarStyle.style7,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          animateTabTransition: true,
          duration: Duration(milliseconds: 300),
          screenTransitionAnimationType: ScreenTransitionAnimationType.slide,
        ),
      ),
      confineToSafeArea: true,
      padding: const EdgeInsets.only(top: 8),
    );
  }
}
