import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_state.dart';

@RoutePage()
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Убеждаемся, что authProvider инициализирован
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Автоматическое перенаправление после завершения загрузки
    ref.listen<AuthNotifierState>(authProvider, (previous, next) {
      if (previous?.isLoading == true && !next.isLoading) {
        if (next.user != null) {
          context.router.replacePath('/');
        } else {
          context.router.replacePath('/sign-in');
        }
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ваш логотип
            FlutterLogo(size: 80),
            const SizedBox(height: 20),
            const Text(
              'Travel Companion',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
