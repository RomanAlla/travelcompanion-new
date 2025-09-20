import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/map/domain/enums/map_mode.dart';
import 'package:travelcompanion/features/map/presentation/providers/map_state_notifier_provider.dart';
import 'package:travelcompanion/features/map/presentation/providers/yandex_map_service_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class YandexMapWidget extends ConsumerStatefulWidget {
  final MapMode mode;
  const YandexMapWidget({super.key, required this.mode});

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
      getPoints();
      _initLocationLayer();
    });
  }

  Future<void> getPoints() async {
    await ref.read(mapStateNotifierProvider.notifier).loadStartPoints(ref);
  }

  void moveToCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _userLocation = await (await _mapControllerCompleter.future)
        .getUserCameraPosition();

    if (_userLocation != null) {
      (await _mapControllerCompleter.future).moveCamera(
        CameraUpdate.newCameraPosition(_userLocation!.copyWith(zoom: 10)),
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 2,
        ),
      );
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

  Future<void> onMapTap(Point point) async {
    final mapController = ref.read(routeBuilderNotifierProvider.notifier);
    mapController.handleTap(point, widget.mode);

    (await _mapControllerCompleter.future).moveCamera(
      animation: MapAnimation(duration: 2.0, type: MapAnimationType.smooth),
      CameraUpdate.newCameraPosition(CameraPosition(target: point, zoom: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buildModePoints = ref.watch(routeBuilderNotifierProvider).mapObjects;
    final watchModePoints = ref.watch(mapStateNotifierProvider).mapObjects;

    return Consumer(
      builder: (context, ref, _) {
        return YandexMap(
          onMapCreated: (controller) async {
            _mapControllerCompleter.complete(controller);
            await Future.delayed(const Duration(milliseconds: 300));
            moveToCurrentLocation();
          },

          mapObjects:
              widget.mode == MapMode.pickMainPoints ||
                  widget.mode == MapMode.pickWayPoints
              ? buildModePoints
              : watchModePoints,
          onMapTap: (tapPoint) async {
            await onMapTap(tapPoint);
            await _buildPedestrianRoute();

            const threshold = 0.005;
            final state = ref.read(mapStateNotifierProvider);

            for (final rp in state.startPoints) {
              final dx = (tapPoint.latitude - rp.latitude).abs();
              final dy = (tapPoint.longitude - rp.longitude).abs();

              if (dx < threshold && dy < threshold) {
                final notifier = ref.read(mapStateNotifierProvider.notifier);
                await notifier.loadRouteByStartPoint(ref, rp.routeId);

                break;
              }
            }
          },

          onUserLocationAdded: (view) async {
            moveToCurrentLocation();
            return view.copyWith(pin: view.pin.copyWith(opacity: 1));
          },
        );
      },
    );
  }
}
