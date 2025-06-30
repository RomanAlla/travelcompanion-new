import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelcompanion/core/router/router.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url: 'https://dvwkdpswmesccgonqroo.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR2d2tkcHN3bWVzY2Nnb25xcm9vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYwNzU0ODgsImV4cCI6MjA2MTY1MTQ4OH0.5BIuF1le3bSnI61Fjkj-w_DCqtpIlh8wHbWIwn_anSk',
    );

    runApp(const ProviderScope(child: TravelApp()));
  } catch (e) {
    rethrow;
  }
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return MaterialApp.router(
      title: 'Travel Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: appRouter.config(
        navigatorObservers: () => [RouteObserver()],
      ),
    );
  }
}
