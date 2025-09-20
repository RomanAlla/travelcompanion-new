import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/features/map/domain/enums/map_mode.dart';
import 'package:travelcompanion/features/map/domain/enums/route_pick_state.dart';
import 'package:travelcompanion/features/map/presentation/providers/map_state_notifier_provider.dart';
import 'package:travelcompanion/features/map/presentation/widgets/helper_widget.dart';
import 'package:travelcompanion/features/map/presentation/widgets/yandex_map_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/page_controller_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/continue_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/modal_point_select_container_widget.dart';

class RoutePickStepScreen extends ConsumerStatefulWidget {
  const RoutePickStepScreen({super.key});

  @override
  ConsumerState<RoutePickStepScreen> createState() =>
      _RoutePickStepWidgetState();
}

class _RoutePickStepWidgetState extends ConsumerState<RoutePickStepScreen> {
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
    final pointState = ref.watch(routeBuilderNotifierProvider);
    final error = ref.watch(
      mapStateNotifierProvider.select((state) => state.error),
    );

    return Scaffold(
      body: Stack(
        children: [
          YandexMapWidget(mode: MapMode.pickMainPoints),
          Consumer(
            builder: (context, ref, child) {
              final helperText =
                  error ??
                  switch (pointState.status) {
                    PointPickState.none => 'Поставьте точку начала маршрута',
                    PointPickState.startPicked =>
                      'Поставьте точку конца маршрута',
                    PointPickState.bothPicked => 'Маршрут готов',
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
                                      style: AppTheme.titleMedium,
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
                                        title:
                                            pointState.status !=
                                                PointPickState.none
                                            ? '${pointState.startPoint?.latitude.toStringAsFixed(4)}, ${pointState.startPoint?.longitude.toStringAsFixed(4)}'
                                            : 'Начальная точка',
                                        onTap: () => _expandedToggle('start'),
                                        isActive:
                                            pointState.status !=
                                            PointPickState.none,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ModalPointSelectContainerWidget(
                                        icon: Icons.flag,
                                        title:
                                            pointState.status ==
                                                PointPickState.bothPicked
                                            ? '${pointState.endPoint?.latitude.toStringAsFixed(4)}, ${pointState.endPoint?.longitude.toStringAsFixed(4)}'
                                            : 'Конечная точка',
                                        onTap: () => _expandedToggle('end'),
                                        isActive:
                                            pointState.status ==
                                            PointPickState.bothPicked,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                pointState.status == PointPickState.bothPicked
                                    ? Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                ref
                                                    .read(
                                                      routeBuilderNotifierProvider
                                                          .notifier,
                                                    )
                                                    .clearAll();
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              label: const Text(
                                                'Очистить',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor:
                                                    AppTheme.lightBlue,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: ContinueActionButtonWidget(
                                              label: 'Готово',
                                              onPressed: () {
                                                ref
                                                    .read(
                                                      pageControllerProvider,
                                                    )
                                                    .nextPage(
                                                      duration: Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      curve: Curves.ease,
                                                    );
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: _hidePanel,
                                          icon: const Icon(Icons.map),
                                          label: Text(
                                            'Выбрать на карте',
                                            style: AppTheme.bodySmallBold
                                                .copyWith(
                                                  color: AppTheme
                                                      .primaryLightColor,
                                                ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
