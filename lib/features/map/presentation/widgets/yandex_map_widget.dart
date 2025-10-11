import 'dart:async';

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
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_point_repository_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/back_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/continue_action_button_widget.dart';
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
      catchPickedRoute();
    });
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
          animation: MapAnimation(duration: 2.0, type: MapAnimationType.smooth),
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
      } else {
        return;
      }
    } catch (e) {
      debugPrint(e.toString());
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
            await _buildPedestrianRoute();

            const threshold = 0.005;
            final state = ref.read(mapStateNotifierProvider);

            for (final rp in state.startPoints) {
              final dx = (tapPoint.latitude - rp.latitude).abs();
              final dy = (tapPoint.longitude - rp.longitude).abs();

              if (dx < threshold && dy < threshold) {
                final notifier = ref.read(mapStateNotifierProvider.notifier);
                await notifier.loadRouteByStartPoint(ref, rp.routeId);
                notifier.setTappedPoint(rp.routeId);

                break;
              }
            }
          },
        ),
        Positioned(
          right: 5,
          bottom: 150,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(5),
            child: IconButton(
              icon: Icon(Icons.gps_fixed, fontWeight: FontWeight.bold),
              style: ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: moveToCurrentLocation,
              color: AppTheme.primaryLightColor,
            ),
          ),
        ),

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
                      SizedBox(width: 30),
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
