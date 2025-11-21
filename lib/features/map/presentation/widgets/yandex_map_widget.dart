import 'dart:async';
import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/core/presentation/providers/use_cases_providers.dart';
import 'package:travelcompanion/core/presentation/router/router.dart';
import 'package:travelcompanion/features/map/domain/enums/map_mode.dart';
import 'package:travelcompanion/features/map/presentation/providers/map_state_notifier_provider.dart';
import 'package:travelcompanion/features/map/presentation/providers/yandex_map_service_provider.dart';
import 'package:travelcompanion/features/map/presentation/widgets/quit_button_widget.dart';
import 'package:travelcompanion/core/domain/entities/route_point_model.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_point_repository_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/back_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/continue_action_button_widget.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class YandexMapWidget extends ConsumerStatefulWidget {
  final MapMode mode;
  final double? targetLatitude;
  final double? targetLongitude;
  const YandexMapWidget({
    super.key,
    required this.mode,
    this.targetLatitude,
    this.targetLongitude,
  });

  @override
  ConsumerState<YandexMapWidget> createState() => _YandexMapWidgetState();
}

class _YandexMapWidgetState extends ConsumerState<YandexMapWidget>
    with RouteAware {
  Completer<YandexMapController> _mapControllerCompleter = Completer();
  CameraPosition? _userLocation;

  @override
  void initState() {
    super.initState();

    _mapControllerCompleter = Completer();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.mode == MapMode.viewAll) {
        await getPoints();
      }
      _initLocationLayer();
      catchPickedRoute();
      
      // Если передана целевая точка, перемещаем камеру к ней
      if (widget.targetLatitude != null && widget.targetLongitude != null) {
        await _moveToTargetPoint();
      }
    });
  }

  Future<void> _moveToTargetPoint() async {
    try {
      // Небольшая задержка для инициализации карты
      await Future.delayed(const Duration(milliseconds: 300));
      final controller = await _mapControllerCompleter.future;
      await controller.moveCamera(
        animation: const MapAnimation(
          duration: 0.5,
          type: MapAnimationType.smooth,
        ),
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(
              latitude: widget.targetLatitude!,
              longitude: widget.targetLongitude!,
            ),
            zoom: 16,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Ошибка при перемещении камеры к точке: $e');
    }
  }

  Future<void> getPoints() async {
    await ref.read(mapStateNotifierProvider.notifier).loadStartPoints(ref);
  }

  Future<void> moveToCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _userLocation = await (await _mapControllerCompleter.future)
        .getUserCameraPosition();

    if (_userLocation != null) {
      (await _mapControllerCompleter.future).moveCamera(
        CameraUpdate.newCameraPosition(_userLocation!.copyWith(zoom: 14)),
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 2,
        ),
      );
    }
  }

  Future<void> zoomIn() async {
    try {
      final controller = await _mapControllerCompleter.future;
      final currentPosition = await controller.getCameraPosition();
      final newZoom = (currentPosition.zoom + 1).clamp(1.0, 20.0);
      controller.moveCamera(
        CameraUpdate.newCameraPosition(currentPosition.copyWith(zoom: newZoom)),
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 0.3,
        ),
      );
    } catch (e) {
      debugPrint('Error zooming in: $e');
    }
  }

  Future<void> zoomOut() async {
    try {
      final controller = await _mapControllerCompleter.future;
      final currentPosition = await controller.getCameraPosition();
      final newZoom = (currentPosition.zoom - 1).clamp(1.0, 20.0);
      controller.moveCamera(
        CameraUpdate.newCameraPosition(currentPosition.copyWith(zoom: newZoom)),
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 0.3,
        ),
      );
    } catch (e) {
      debugPrint('Error zooming out: $e');
    }
  }

  Future<void> _initLocationLayer() async {
    final service = ref.read(yandexMapServiceProvider);
    await service.initLocationLayer(_mapControllerCompleter, ref, context);
  }

  Future<void> _buildPedestrianRoute() async {
    final service = ref.read(yandexMapServiceProvider);
    await service.buildPedestrianRoute(ref);
  }

  /// Вычисление расстояния между двумя точками (в градусах)
  double _calculateDistance(Point point1, Point point2) {
    final dx = point1.latitude - point2.latitude;
    final dy = point1.longitude - point2.longitude;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Обработка тапа на карту
  Future<void> onMapTap(Point tapPoint) async {
    // Режим создания маршрута
    if (widget.mode == MapMode.pickMainPoints ||
        widget.mode == MapMode.pickWayPoints) {
      final mapController = ref.read(routeBuilderNotifierProvider.notifier);
      mapController.handleTap(tapPoint, widget.mode, ref);

      // Перемещаем камеру к точке
      (await _mapControllerCompleter.future).moveCamera(
        animation: const MapAnimation(
          duration: 0.5,
          type: MapAnimationType.smooth,
        ),
        CameraUpdate.newCameraPosition(
          CameraPosition(target: tapPoint, zoom: 14),
        ),
      );

      // Строим маршрут после добавления точки
      if (widget.mode == MapMode.pickMainPoints) {
        await _buildPedestrianRoute();
      }
      return;
    }

    // Режим просмотра всех маршрутов - проверяем нажатие на метки
    if (widget.mode == MapMode.viewAll) {
      final state = ref.read(mapStateNotifierProvider);
      final startPoints = state.startPoints;

      if (startPoints.isEmpty) {
        return;
      }

      // Ищем ближайшую метку к точке тапа
      RoutePointsModel? nearestPoint;
      double minDistance = double.infinity;

      // Порог для определения нажатия на метку (примерно 50-100 метров)
      // Зависит от зума, но используем фиксированное значение для простоты
      const threshold = 0.001; // примерно 100 метров

      for (final routePoint in startPoints) {
        final distance = _calculateDistance(tapPoint, routePoint.point);

        if (distance < threshold && distance < minDistance) {
          minDistance = distance;
          nearestPoint = routePoint;
        }
      }

      // Если нашли ближайшую метку в пределах порога
      if (nearestPoint != null) {
        debugPrint('Нажатие на метку маршрута: ${nearestPoint.routeId}');
        debugPrint('Расстояние до метки: $minDistance');

        try {
          final notifier = ref.read(mapStateNotifierProvider.notifier);

          // Загружаем маршрут
          await notifier.loadRouteByStartPoint(ref, nearestPoint.routeId);
          notifier.setTappedPoint(nearestPoint.routeId);

          // Перемещаем камеру к начальной точке маршрута
          final controller = await _mapControllerCompleter.future;
          await controller.moveCamera(
            animation: const MapAnimation(
              duration: 0.5,
              type: MapAnimationType.smooth,
            ),
            CameraUpdate.newCameraPosition(
              CameraPosition(target: nearestPoint.point, zoom: 14),
            ),
          );
        } catch (e, stackTrace) {
          debugPrint('Ошибка при обработке нажатия на метку: $e');
          debugPrint('Stack trace: $stackTrace');
        }
      }
    }
  }

  Future<void> _toRouteDescription(String routeId) async {
    final route = await ref
        .read(routeRepositoryProvider)
        .getRoutesById(id: routeId);
    if (!mounted) return;
    context.router.push(RouteDescriptionRoute(routeId: routeId, route: route));
  }

  void _handleQuit() {
    final notifier = ref.read(mapStateNotifierProvider.notifier);
    notifier.clearTappedPoint();
    notifier.clearPastPolilynes();
    notifier.clearPickedRoute();
    ref.invalidate(mapStateNotifierProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.router.pushAndPopUntil(
        MainRoutesRoute(),
        predicate: (route) => false,
      );
    });
  }

  void _handleClearTappedPoint() {
    final notifier = ref.read(mapStateNotifierProvider.notifier);
    notifier.clearTappedPoint();
    notifier.clearPastPolilynes();
    notifier.clearPickedRoute();
  }

  void catchPickedRoute() async {
    try {
      final route = ref.watch(mapStateNotifierProvider).pickedRoute;

      if (route != null) {
        final point = await ref
            .read(routePointRepositoryProvider)
            .getStartPoint(id: route.id);
        (await _mapControllerCompleter.future).moveCamera(
          animation: const MapAnimation(
            duration: 2.0,
            type: MapAnimationType.smooth,
          ),
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: Point(
                latitude: point.latitude,
                longitude: point.longitude,
              ),
              zoom: 16,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Ошибка в catchPickedRoute: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapStateNotifierProvider);
    final watchModePoints = state.mapObjects;
    final buildModePoints = ref.watch(routeBuilderNotifierProvider).mapObjects;

    return Stack(
      children: [
        YandexMap(
          onMapCreated: (controller) async {
            _mapControllerCompleter.complete(controller);
            await Future.delayed(const Duration(milliseconds: 300));
          },
          mapObjects:
              widget.mode == MapMode.pickMainPoints ||
                  widget.mode == MapMode.pickWayPoints
              ? buildModePoints
              : watchModePoints,
          onMapTap: (tapPoint) async {
            await onMapTap(tapPoint);
          },
        ),
        // Кнопки масштабирования
        Positioned(
          bottom: 280,
          right: 5,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, fontWeight: FontWeight.bold),
                    style: ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: zoomIn,
                    color: AppTheme.primaryLightColor,
                  ),
                  Container(
                    width: 48,
                    height: 1,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove, fontWeight: FontWeight.bold),
                    style: ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: zoomOut,
                    color: AppTheme.primaryLightColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Кнопка навигации к текущей позиции
        Positioned(
          right: 5,
          bottom: 240,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(5),
            child: IconButton(
              icon: const Icon(Icons.gps_fixed, fontWeight: FontWeight.bold),
              style: ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: moveToCurrentLocation,
              color: AppTheme.primaryLightColor,
            ),
          ),
        ),
        // Кнопки действий
        state.hasTappedPoint
            ? SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BackActionButtonWidget(
                        onPressed: _handleClearTappedPoint,
                        label: 'Вернуться',
                      ),
                      const SizedBox(width: 30),
                      ContinueActionButtonWidget(
                        onPressed: () =>
                            _toRouteDescription(state.tappedRouteId!),
                        label: 'Продолжить',
                      ),
                    ],
                  ),
                ),
              )
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: QuitButtonWidget(onPressed: _handleQuit),
                  ),
                ),
              ),
      ],
    );
  }
}
