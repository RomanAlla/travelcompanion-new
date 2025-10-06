import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/exceptions/app_exception.dart';
import 'package:travelcompanion/core/presentation/router/router.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/features/main/presentation/providers/routes_filter_provider.dart';
import 'package:travelcompanion/features/map/presentation/providers/map_state_notifier_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/page_controller_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/routes_list_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/back_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/continue_action_button_widget.dart';

class ConfirmStepScreen extends ConsumerStatefulWidget {
  const ConfirmStepScreen({super.key});

  @override
  ConsumerState<ConfirmStepScreen> createState() => _ConfirmStepScreenState();
}

class _ConfirmStepScreenState extends ConsumerState<ConfirmStepScreen> {
  bool _isLoading = false;

  Future<void> createRoute(WidgetRef ref, BuildContext context) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(mapStateNotifierProvider.notifier).createRoute(ref);

      ref.invalidate(filteredRoutesProvider);
      ref.invalidate(routeListProvider);

      if (context.mounted) {
        context.router.pushAndPopUntil(
          MainRoutesRoute(),
          predicate: (route) => false,
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Произошла неизвестная ошибка...')),
        );
      }

      throw AppException(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
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
                  onPressed: _isLoading
                      ? () {}
                      : () {
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
                    _isLoading ? () {} : createRoute(ref, context);
                  },
                  label: 'Завершить',
                ),
              ],
            ),
          ],
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryLightColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
