import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travelcompanion/features/map/presentation/providers/map_state_notifier_provider.dart';
import 'package:travelcompanion/core/domain/entities/route_point_model.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

//1
class YandexMapService {
  Future<void> buildPedestrianRoute(WidgetRef ref) async {
    // Сохраняем ссылки на notifiers до асинхронных операций
    // чтобы избежать использования ref после dispose
    final mapStateNotifier = ref.read(mapStateNotifierProvider.notifier);
    final routeBuilderNotifier = ref.read(
      routeBuilderNotifierProvider.notifier,
    );

    // Очищаем предыдущую ошибку в начале новой попытки построения
    mapStateNotifier.clearError();
    // Устанавливаем состояние загрузки
    mapStateNotifier.setLoading(true);

    try {
      final builderState = ref.read(routeBuilderNotifierProvider);
      final mapState = ref.read(mapStateNotifierProvider);

      final List<RequestPoint> requestPoints = [];

      // Проверяем, в каком режиме мы работаем
      final isViewMode = mapState.selectedRouteId != null;

      if (isViewMode) {
        // Режим просмотра - используем точки из выбранного маршрута
        final pts = mapState.selectedRoutePoints;
        debugPrint('Режим просмотра, точек маршрута: ${pts.length}');

        if (pts.isEmpty) {
          debugPrint('Точки маршрута пусты');
          mapStateNotifier.setLoading(false);
          return;
        }

        final startPoints = pts.where((p) => p.type == 'start').toList();
        final endPoints = pts.where((p) => p.type == 'end').toList();
        final waypoints = pts.where((p) => p.type == 'waypoint').toList();

        if (startPoints.isEmpty || endPoints.isEmpty) {
          debugPrint('Отсутствуют начальная или конечная точка');
          mapStateNotifier.setLoading(false);
          return;
        }

        final start = startPoints.first;
        final end = endPoints.first;

        debugPrint('Начальная точка: ${start.latitude}, ${start.longitude}');
        debugPrint('Конечная точка: ${end.latitude}, ${end.longitude}');
        debugPrint('Промежуточных точек: ${waypoints.length}');

        requestPoints.add(
          RequestPoint(
            point: start.point,
            requestPointType: RequestPointType.wayPoint,
          ),
        );

        for (final wp in waypoints) {
          requestPoints.add(
            RequestPoint(
              point: wp.point,
              requestPointType: RequestPointType.viaPoint,
            ),
          );
        }
        requestPoints.add(
          RequestPoint(
            point: end.point,
            requestPointType: RequestPointType.wayPoint,
          ),
        );
      } else {
        // Режим создания маршрута - используем точки из routeBuilderNotifier
        debugPrint('Режим создания маршрута');
        if (builderState.startPoint == null || builderState.endPoint == null) {
          debugPrint('Точки не выбраны в режиме создания');
          mapStateNotifier.setLoading(false);
          return;
        }

        requestPoints.add(
          RequestPoint(
            point: builderState.startPoint!,
            requestPointType: RequestPointType.wayPoint,
          ),
        );
        if (builderState.wayPoints != null &&
            builderState.wayPoints!.isNotEmpty) {
          for (final p in builderState.wayPoints!) {
            requestPoints.add(
              RequestPoint(
                point: p,
                requestPointType: RequestPointType.viaPoint,
              ),
            );
          }
        }
        requestPoints.add(
          RequestPoint(
            point: builderState.endPoint!,
            requestPointType: RequestPointType.wayPoint,
          ),
        );
      }

      if (requestPoints.length < 2) {
        debugPrint(
          'Недостаточно точек для построения маршрута: ${requestPoints.length}',
        );
        mapStateNotifier.setLoading(false);
        return;
      }

      debugPrint('Запрос к YandexPedestrian с ${requestPoints.length} точками');
      final (session, resultFuture) = await YandexPedestrian.requestRoutes(
        points: requestPoints,
        timeOptions: const TimeOptions(),
        avoidSteep: false,
      );

      final result = await resultFuture;
      debugPrint(
        'Ответ от YandexPedestrian: ${result.routes?.length ?? 0} маршрутов',
      );

      if (result.routes == null || result.routes!.isEmpty) {
        debugPrint('Маршруты не получены от Yandex API');
        mapStateNotifier.setError('Не удалось построить маршрут');
        mapStateNotifier.setLoading(false);
        if (!isViewMode) {
          routeBuilderNotifier.setRoutes([], null);
        } else {
          mapStateNotifier.setRoutes([]);
        }
        return;
      }

      final route = result.routes!.first;
      final polyline = PolylineMapObject(
        mapId: MapObjectId(
          'pedestrian_route_${DateTime.now().millisecondsSinceEpoch}',
        ),
        polyline: Polyline(points: route.geometry.points),
        strokeColor: Colors.blue,
        strokeWidth: 5,
      );

      debugPrint(
        'Маршрут построен успешно, точек в полилинии: ${route.geometry.points.length}',
      );

      // Сохраняем построенный маршрут в зависимости от режима
      if (isViewMode) {
        // Режим просмотра - сохраняем в mapStateNotifier
        mapStateNotifier.setRoutes([polyline]);
        debugPrint('Маршрут сохранен в MapState');
      } else {
        // Режим создания - сохраняем в routeBuilderNotifier
        routeBuilderNotifier.setRoutes([polyline], null);
        debugPrint('Маршрут сохранен в RouteBuilderNotifier');
      }

      // Очищаем ошибку и завершаем загрузку после успешного построения
      mapStateNotifier.clearError();
      mapStateNotifier.setLoading(false);
    } catch (e, st) {
      debugPrint('buildPedestrianRoute error: $e');
      debugPrint('Stack trace: $st');
      // Используем сохраненные ссылки, чтобы избежать использования ref после dispose
      try {
        mapStateNotifier.setError('Ошибка построения маршрута: $e');
        mapStateNotifier.setLoading(false);
        final mapState = ref.read(mapStateNotifierProvider);
        if (mapState.selectedRouteId != null) {
          mapStateNotifier.setRoutes([]);
        } else {
          routeBuilderNotifier.setRoutes([], null);
        }
      } catch (disposeError) {
        // Игнорируем ошибки, если виджет уже удален
        debugPrint('Widget disposed, ignoring state updates: $disposeError');
      }
    }
  }

  Future<void> initLocationLayer(
    Completer<YandexMapController> controller,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      (await controller.future).toggleUserLayer(visible: true);
    } else {
      if (status.isPermanentlyDenied) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Permission Required'),
              content: const Text(
                'Please enable location permissions in app settings to use this feature',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => openAppSettings(),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permission is required to show your position',
              ),
              duration: Duration(seconds: 2),
            ),
          );
        });
      }
    }
  }

  Future<bool> checkLocationServices(BuildContext context) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Services Disabled'),
            content: const Text('Please enable location services'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
      return false;
    }
    return true;
  }
}
