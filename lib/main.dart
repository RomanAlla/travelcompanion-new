import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/core/router/router.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: 'assets/.env');
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    runApp(const ProviderScope(child: TravelApp()));
  } catch (e) {
    rethrow;
  }
}

class TravelApp extends ConsumerWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final appRouter = AppRouter();

    return userProfile.when(
      data: (user) {
        if (user == null) {
          return const CircularProgressIndicator();
        }
        return MaterialApp.router(
          title: 'Travel Companion',
          theme: AppTheme.lightTheme,
          routerConfig: appRouter.config(
            navigatorObservers: () => [RouteObserver()],
          ),
        );
      },
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Ошибка: $e'))),
      ),
    );
  }
}
