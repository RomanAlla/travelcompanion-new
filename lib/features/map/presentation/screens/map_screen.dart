import 'dart:async';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travelcompanion/core/error/error_handler.dart';
import 'package:travelcompanion/features/details_route/presentation/screens/route_description_content.dart';
import 'package:travelcompanion/features/map/domain/enums/map_mode.dart';
import 'package:travelcompanion/features/map/data/services/map_controller.dart';
import 'package:travelcompanion/features/map/domain/enums/route_pick_state.dart';
import 'package:travelcompanion/features/map/presentation/providers/map_controller.dart';
import 'package:travelcompanion/features/map/presentation/providers/route_pick_controller.dart';
import 'package:travelcompanion/features/map/presentation/widgets/helper_widget.dart';
import 'package:travelcompanion/features/routes/data/models/interesting_route_points_model.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';
import 'package:travelcompanion/features/routes/presentation/providers/interesting_route_points_repository_provider.dart';
import 'package:travelcompanion/features/routes/presentation/providers/route_details_provider.dart';
import 'package:travelcompanion/features/routes/presentation/providers/route_point_repository_provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:geolocator/geolocator.dart';

@RoutePage()
class MapScreen extends ConsumerStatefulWidget {
  final bool showObjects;
  const MapScreen({super.key, required this.showObjects});

  @override
  ConsumerState<MapScreen> createState() => _MapChangeModeState();
}

class _MapChangeModeState extends ConsumerState<MapScreen> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  RouteModel? selectedRoute;
  List<InterestingRoutePointsModel> selectedRoutePoints = [];
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
          YandexMapWidget(mode: MapMode.viewAll),
          if (_showInstruction) HelperWidget(text: 'test'),
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
  final List<MapObject> mapObjects = [];
  final _mapController = MyMapController();
  final List<PlacemarkMapObject> selectedPoints = [];
  CameraPosition? _userLocation;

  @override
  void initState() {
    super.initState();
    _mapControllerCompleter = Completer();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initLocationLayer();
      if (await _checkLocationServices()) {
        if (widget.mode == MapMode.viewAll) getAllPoints();
      }
    });
  }

  Future<void> getAllPoints() async {
    try {
      final rep = ref.read(routePointRepositoryProvider);
      final points = await rep.getAllPoints();
      setState(() {
        _mapController.clearAll();
        _mapController.addRouteMarkers(points, onRouteMarkerTap);
      });
    } catch (e) {
      ErrorHandler.getErrorMessage(e);
    }
  }

  Future<void> onRouteMarkerTap(RouteModel route) async {
    final pointsRep = ref.read(interestingRoutePointsRepositoryProvider);
    final points = await pointsRep.getInterestingPointsByRouteId(route.id);

    setState(() {
      _mapController.removeInterestingPoints();
      _mapController.addInterestingPoints(points);
    });

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.05,
          minChildSize: 0.05,
          maxChildSize: 0.9,
          snap: true,
          snapSizes: const [0.05, 0.9],
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, _) {
                final detailsAsync = ref.watch(routeDetailsProvider(route));
                return detailsAsync.when(
                  data: (details) => Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          RouteDescriptionContent(
                            creator: details.creator,
                            route: route,
                            commentsCount: details.commentsCount,
                            averageRating: details.averageRating,
                            userRoutesCount: details.userRoutesCount,
                            averageUserRoutesRating:
                                details.averageUserRoutesRating,
                            commentsList: details.commentsList,
                            myItems: details.myItems,
                            currentIndex: details.currentIndex,
                          ),
                        ],
                      ),
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Ошибка: $e')),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                );
              },
            );
          },
        );
      },
    );
  }

  void onMapTap(Point point) async {
    final stateNotifier = ref.read(routePickControllerProvider.notifier);
    final currentState = ref.read(routePickControllerProvider);

    if (currentState == RoutePickState.bothPicked) {
      setState(() {
        selectedPoints.clear();
        mapObjects.removeWhere((obj) => obj.mapId.value == 'pedestrian_route');
      });

      stateNotifier.reset();
      return;
    }

    final mapController = ref.read(mapControllerProvider);
    final marker = mapController.onMapTap(point, widget.mode, selectedPoints);

    setState(() {
      if (marker != null) selectedPoints.add(marker);
    });

    final controller = await _mapControllerCompleter.future;

    controller.moveCamera(
      animation: MapAnimation(type: MapAnimationType.smooth),
      CameraUpdate.newCameraPosition(CameraPosition(target: point)),
    );

    stateNotifier.selectPoint(point);

    final updatedState = ref.read(routePickControllerProvider);
    if (updatedState == RoutePickState.bothPicked) {
      final start = stateNotifier.startPoint;
      final end = stateNotifier.endPoint;

      if (start != null && end != null) {
        await buildPedestrianRoute(
          start: start,
          end: end,
          controller: controller,
        );
      }
    }
  }

  Future<void> buildPedestrianRoute({
    required Point start,
    required Point end,
    required YandexMapController controller,
  }) async {
    try {
      final (session, resultFuture) = await YandexPedestrian.requestRoutes(
        points: [
          RequestPoint(
            point: start,
            requestPointType: RequestPointType.wayPoint,
          ),
          RequestPoint(point: end, requestPointType: RequestPointType.wayPoint),
        ],
        timeOptions: const TimeOptions(),
        avoidSteep: false,
      );

      final result = await resultFuture;

      if ((result.routes?.isNotEmpty ?? false)) {
        final route = result.routes!.first;

        final polyline = PolylineMapObject(
          mapId: const MapObjectId('pedestrian_route'),
          polyline: Polyline(points: route.geometry.points),
          strokeColor: Colors.blue,
          strokeWidth: 5,
        );

        setState(() {
          mapObjects.removeWhere(
            (obj) => obj.mapId.value == 'pedestrian_route',
          );
          mapObjects.add(polyline);
        });
      } else if (result.error != null) {
        debugPrint('Ошибка построения маршрута: ${result.error}');
      } else {
        debugPrint('Маршрут не найден, и ошибки нет.');
      }
    } catch (e, stackTrace) {
      debugPrint('Исключение при построении маршрута: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  Future<void> _initLocationLayer() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      (await _mapControllerCompleter.future).toggleUserLayer(visible: true);
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

  Future<bool> _checkLocationServices() async {
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

  @override
  Widget build(BuildContext context) {
    return YandexMap(
      onMapCreated: (controller) async {
        _mapControllerCompleter.complete(controller);
        await Future.delayed(const Duration(milliseconds: 300));
        moveToCurrentLocation();
      },
      mapObjects: [
        ...mapObjects,
        if (widget.mode == MapMode.pickPoints) ...selectedPoints,
      ],
      onMapTap: (point) {
        onMapTap(point);

        setState(() {
          mapObjects.removeWhere(
            (obj) => obj.mapId.value.startsWith('interest_'),
          );
        });
      },
      onUserLocationAdded: (view) async {
        moveToCurrentLocation();

        return view.copyWith(pin: view.pin.copyWith(opacity: 1));
      },
    );
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
}
