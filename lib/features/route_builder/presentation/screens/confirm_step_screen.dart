import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/router/router.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/features/main/presentation/providers/routes_filter_provider.dart';
import 'package:travelcompanion/features/map/presentation/providers/map_state_notifier_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/page_controller_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/routes_list_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/back_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/continue_action_button_widget.dart';

class ConfirmStepScreen extends ConsumerWidget {
  const ConfirmStepScreen({super.key});

  Future<void> createRoute(WidgetRef ref, BuildContext context) async {
    try {
      ref.read(mapStateNotifierProvider.notifier).createRoute(ref);
      if (!context.mounted) return;

      ref.invalidate(filteredRoutesProvider);
      ref.invalidate(routesListProvider);

      context.router.pushAndPopUntil(
        MainRoutesRoute(),
        predicate: (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Произошла неизвестная ошибка...')),
      );
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_outline,
          color: AppTheme.primaryLightColor,
          size: 85,
        ),
        const SizedBox(height: 24),
        const Text(
          textAlign: TextAlign.center,
          'Завершить маршрут?',
          style: AppTheme.titleLargeThin,
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BackActionButtonWidget(
              label: 'Назад',
              onPressed: () {
                ref
                    .read(pageControllerProvider)
                    .previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
              },
            ),
            ContinueActionButtonWidget(
              onPressed: () {
                createRoute(ref, context);
              },
              label: 'Завершить',
            ),
          ],
        ),
      ],
    );
  }
}
