import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/page_controller_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:travelcompanion/features/route_builder/presentation/screens/confirm_step_screen.dart';
import 'package:travelcompanion/features/route_builder/presentation/screens/main_info_step_screen.dart';
import 'package:travelcompanion/features/route_builder/presentation/screens/photo_step_screen.dart';
import 'package:travelcompanion/features/route_builder/presentation/screens/privacy_step_screen.dart';
import 'package:travelcompanion/features/route_builder/presentation/screens/route_pick_step_screen.dart';
import 'package:travelcompanion/features/route_builder/presentation/screens/tips_step_screen.dart';
import 'package:travelcompanion/features/route_builder/presentation/screens/way_points_step_screen.dart';
import 'package:travelcompanion/main.dart';

@RoutePage()
class CreateRouteScreen extends ConsumerStatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  ConsumerState<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends ConsumerState<CreateRouteScreen>
    with RouteAware {
  int _currentPage = 0;
  static const int _totalSteps = 7;

  @override
  void didPop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(routeBuilderNotifierProvider.notifier).clearAll(ref);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(pageControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: controller,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              RoutePickStepScreen(),
              MainInfoStepScreen(),
              PhotoStepScreen(),
              WayPointsStepScreen(),
              TipsStepScreen(),
              PrivacyStepScreen(),
              ConfirmStepScreen(),
            ],
          ),
        ],
      ),
    );
  }
}
