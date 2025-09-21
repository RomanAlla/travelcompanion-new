import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/features/map/domain/enums/map_mode.dart';
import 'package:travelcompanion/features/map/presentation/widgets/yandex_map_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/page_controller_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/back_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/continue_action_button_widget.dart';

class WayPointsStepScreen extends ConsumerWidget {
  const WayPointsStepScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        YandexMapWidget(mode: MapMode.pickWayPoints),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppTheme.primaryLightColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Интересные точки',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      style: ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: WidgetStatePropertyAll(Size.zero),
                        padding: WidgetStatePropertyAll(EdgeInsets.zero),
                        elevation: WidgetStatePropertyAll(0),
                      ),
                      onPressed: () {
                        ref
                            .read(routeBuilderNotifierProvider.notifier)
                            .deleteWayPoints(ref);
                        if (context.mounted) {
                          ref.invalidate(routeBuilderNotifierProvider);
                        }
                      },
                      color: Colors.red,
                      icon: Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        'Нажмите на карту, чтобы добавить промежуточную точку маршрута ',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: BackActionButtonWidget(
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
                    ),

                    SizedBox(width: 90),

                    Expanded(
                      child: ContinueActionButtonWidget(
                        label: 'Готово',
                        onPressed: () {
                          ref
                              .read(pageControllerProvider)
                              .nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
