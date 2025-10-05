import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travelcompanion/features/map/presentation/providers/map_state_notifier_provider.dart';
import 'package:travelcompanion/core/domain/entities/route_point_model.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class YandexMapService {
  Future<void> buildPedestrianRoute(WidgetRef ref) async {
    try {
      final builderState = ref.read(routeBuilderNotifierProvider);
      final mapState = ref.read(mapStateNotifierProvider);

      final List<RequestPoint> requestPoints = [];

      if (mapState.selectedRouteId != null) {
        final pts = mapState.selectedRoutePoints;
        if (pts.isEmpty) return;

        final start = pts.firstWhere((p) => p.type == 'start');
        final end = pts.firstWhere((p) => p.type == 'end');
        final waypoints = pts.where((p) => p.type == 'waypoint').toList();

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
        if (builderState.startPoint == null || builderState.endPoint == null) {
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

      if (requestPoints.length < 2) return;

      final (session, resultFuture) = await YandexPedestrian.requestRoutes(
        points: requestPoints,
        timeOptions: const TimeOptions(),
        avoidSteep: false,
      );

      final result = await resultFuture;

      if (result.routes == null || result.routes!.isEmpty) {
        ref
            .read(mapStateNotifierProvider.notifier)
            .setError('Не удалось построить маршрут');

        ref.read(routeBuilderNotifierProvider.notifier).setRoutes([]);
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

      if (mapState.selectedRouteId != null) {
        final mapNotifier = ref.read(mapStateNotifierProvider.notifier);

        mapNotifier.state = mapNotifier.state.copyWith(routes: [polyline]);
      } else {
        ref.read(routeBuilderNotifierProvider.notifier).setRoutes([polyline]);
      }

      ref.read(mapStateNotifierProvider.notifier).clearError();
    } catch (e, st) {
      debugPrint('buildPedestrianRoute error: $e\n$st');
      ref
          .read(mapStateNotifierProvider.notifier)
          .setError('Ошибка построения маршрута: $e');
      ref.read(routeBuilderNotifierProvider.notifier).setRoutes([]);
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
