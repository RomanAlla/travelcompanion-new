import 'dart:async';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/map/domain/enums/map_mode.dart';
import 'package:travelcompanion/features/map/presentation/providers/map_state_notifier_provider.dart';
import 'package:travelcompanion/features/map/presentation/providers/yandex_map_service_provider.dart';
import 'package:travelcompanion/features/map/presentation/widgets/helper_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

@RoutePage()
class MapScreen extends ConsumerStatefulWidget {
  final MapMode mode;
  const MapScreen({super.key, this.mode = MapMode.viewAll});

  @override
  ConsumerState<MapScreen> createState() => _MapChangeModeState();
}

class _MapChangeModeState extends ConsumerState<MapScreen> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final bool _showInstruction = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sheetController.addListener(() {
        if (_sheetController.size <= 0.3) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _sheetController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YandexMapWidget(mode: widget.mode),
          if (_showInstruction)
            HelperWidget(
              text: 'Нажмите на метку, чтобы увидеть полный маршрут',
            ),
        ],
      ),
    );
  }
}

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

  Future<void> getRoutes() async {
    // try{
    //   final routes = await ref.read(routeRepositoryProvider).getRoutes();

    // }
  }
  Future<void> getFullRoute(MapObject mapObject, Point point) async {
    try {
      if (mapObject is PlacemarkMapObject) {
        final mapId = mapObject.mapId.value;
        if (mapId.startsWith('start_')) {
          final routeId = mapId.replaceFirst('start_', '');
          ref
              .read(mapStateNotifierProvider.notifier)
              .loadRouteByStartPoint(ref, routeId);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
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
            // обработка режима построения маршрута
            await onMapTap(tapPoint);
            await _buildPedestrianRoute();

            // обработка выбора маршрута по тапу на стартовую точку
            const threshold =
                0.005; // радиус в градусах (~50м, подбери под свой zoom)
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
