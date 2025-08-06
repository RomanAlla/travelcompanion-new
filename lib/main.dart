import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/core/router/router.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
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
    final appRouter = AppRouter(authGuard: AuthGuard());

    return MaterialApp.router(
      title: 'Travel Companion',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter.config(navigatorObservers: () => [routeObserver]),
    );
  }
}
