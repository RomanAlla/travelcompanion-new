import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/map/domain/enums/map_mode.dart';
import 'package:travelcompanion/features/map/domain/enums/route_pick_state.dart';
import 'package:travelcompanion/features/map/presentation/providers/route_pick_controller.dart';
import 'package:travelcompanion/features/map/presentation/screens/map_screen.dart';
import 'package:travelcompanion/features/map/presentation/widgets/helper_widget.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/modal_point_select_container_widget.dart';

class RoutePickStepWidget extends ConsumerStatefulWidget {
  const RoutePickStepWidget({super.key});

  @override
  ConsumerState<RoutePickStepWidget> createState() =>
      _RoutePickStepWidgetState();
}

class _RoutePickStepWidgetState extends ConsumerState<RoutePickStepWidget> {
  bool isExpanded = false;
  bool isHidden = false;
  String? pointType;

  void _expandedToggle(String? newPointType) {
    setState(() {
      isExpanded = !isExpanded;
      if (!isExpanded) {
        isHidden = false;
      }
      pointType = newPointType;
    });
  }

  void _hidePanel() {
    setState(() {
      isExpanded = false;
      isHidden = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double collapsedHeight = 180;
    double expandedHeight = MediaQuery.of(context).size.height * 0.7;
    final pointState = ref.watch(routePickControllerProvider);
    final points = ref.read(routePickControllerProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          YandexMapWidget(mode: MapMode.pickPoints),
          Consumer(
            builder: (context, ref, child) {
              final helperText = switch (pointState) {
                RoutePickState.none => 'Поставьте точку начала маршрута',
                RoutePickState.startPicked => 'Поставьте точку конца маршрута',
                RoutePickState.bothPicked => 'Маршрут готов',
              };

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: HelperWidget(
                  key: ValueKey<String>(helperText),
                  text: helperText,
                ),
              );
            },
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: isHidden ? -expandedHeight : 0,
            right: 0,
            left: 0,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(isExpanded ? 0 : 24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  GestureDetector(
                    onTap: () => _expandedToggle(null),
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: SizedBox(
                      height: isExpanded
                          ? expandedHeight - 20
                          : collapsedHeight,
                      child: SingleChildScrollView(
                        physics: isExpanded
                            ? const AlwaysScrollableScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            children: [
                              if (isExpanded) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () => _expandedToggle(null),
                                      icon: Icon(Icons.close),
                                    ),
                                    Text(
                                      pointType == 'start'
                                          ? 'Поиск начальной точки'
                                          : 'Поиск конечной точки',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.search),
                                    hintText: 'Введите адрес или место',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ] else ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: ModalPointSelectContainerWidget(
                                        icon: Icons.location_on,
                                        title: pointState != RoutePickState.none
                                            ? '${points.startPoint?.latitude.toStringAsFixed(4)}, ${points.startPoint?.longitude.toStringAsFixed(4)}'
                                            : 'Начальная точка',
                                        onTap: () => _expandedToggle('start'),
                                        isActive:
                                            pointState != RoutePickState.none,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ModalPointSelectContainerWidget(
                                        icon: Icons.flag,
                                        title:
                                            pointState ==
                                                RoutePickState.bothPicked
                                            ? '${points.endPoint?.latitude.toStringAsFixed(4)}, ${points.endPoint?.longitude.toStringAsFixed(4)}'
                                            : 'Конечная точка',
                                        onTap: () => _expandedToggle('end'),
                                        isActive:
                                            pointState ==
                                            RoutePickState.bothPicked,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _hidePanel,
                                    icon: const Icon(Icons.map),
                                    label: const Text('Выбрать на карте'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isHidden)
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 4,
                onPressed: () => _expandedToggle(null),
                child: const Icon(Icons.keyboard_arrow_up),
              ),
            ),
        ],
      ),
    );
  }
}
