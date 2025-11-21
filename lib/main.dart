import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/core/presentation/router/router.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/firebase_options.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await dotenv.load(fileName: 'assets/.env');
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    runApp(const ProviderScope(overrides: [], child: TravelApp()));
  } catch (e) {
    rethrow;
  }
}

class TravelApp extends ConsumerStatefulWidget {
  const TravelApp({super.key});

  @override
  ConsumerState<TravelApp> createState() => _TravelAppState();
}

class _TravelAppState extends ConsumerState<TravelApp> {
  AppRouter? _appRouter;

  @override
  Widget build(BuildContext context) {
    _appRouter ??= AppRouter(authGuard: AuthGuard(ref));
    return MaterialApp.router(
      key: const ValueKey('app_router'),
      title: 'Travel Companion',
      theme: AppTheme.lightTheme,
      routerConfig: _appRouter!.config(
        navigatorObservers: () => [routeObserver],
      ),
    );
  }
}
