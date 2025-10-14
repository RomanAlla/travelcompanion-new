import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';
import 'package:travelcompanion/features/auth/presentation/providers/user_notifier_provider.dart';
import 'package:travelcompanion/features/map/presentation/providers/yandex_map_service_provider.dart';
import 'package:travelcompanion/core/domain/entities/route_point_model.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_point_repository_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_repository_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/tip_repository_provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapState {
  final List<RoutePointsModel> allRoutePoints;
  final List<PolylineMapObject> routes;
  final String? error;
  final bool isLoading;
  final bool showAllStartPoints;
  final String? selectedRouteId;
  final String? tappedRouteId;
  final RouteModel? pickedRoute;

  const MapState({
    this.error,
    this.allRoutePoints = const [],
    this.routes = const [],
    this.isLoading = false,
    this.showAllStartPoints = true,
    this.selectedRouteId,
    this.tappedRouteId,
    this.pickedRoute,
  });

  MapState copyWith({
    List<RoutePointsModel>? allRoutePoints,
    List<PolylineMapObject>? routes,
    bool? isLoading,
    String? error,
    bool? showAllStartPoints,
    String? selectedRouteId,
    String? tappedRouteId,
    RouteModel? pickedRoute,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      allRoutePoints: allRoutePoints ?? this.allRoutePoints,
      routes: routes ?? this.routes,
      error: error ?? this.error,
      showAllStartPoints: showAllStartPoints ?? this.showAllStartPoints,
      selectedRouteId: selectedRouteId ?? this.selectedRouteId,
      tappedRouteId: tappedRouteId,
      pickedRoute: pickedRoute ?? this.pickedRoute,
    );
  }

  bool get hasTappedPoint {
    final result = tappedRouteId != null;

    return result;
  }

  List<RoutePointsModel> get startPoints =>
      allRoutePoints.where((p) => p.type == 'start').toList();

  List<RoutePointsModel> get endPoints =>
      allRoutePoints.where((p) => p.type == 'end').toList();

  List<RoutePointsModel> get wayPoints =>
      allRoutePoints.where((p) => p.type == 'waypoint').toList();

  List<RoutePointsModel> get selectedRoutePoints => selectedRouteId != null
      ? allRoutePoints.where((p) => p.routeId == selectedRouteId).toList()
      : [];

  Point? get selectedStartPoint {
    final points = selectedRoutePoints.where((p) => p.type == 'start');
    return points.isNotEmpty ? points.first.point : null;
  }

  Point? get selectedEndPoint {
    final points = selectedRoutePoints.where((p) => p.type == 'end');
    return points.isNotEmpty ? points.first.point : null;
  }

  List<Point> get selectedWayPoints => selectedRoutePoints
      .where((p) => p.type == 'waypoint')
      .map((p) => p.point)
      .toList();

  List<MapObject> get mapObjects {
    final List<MapObject> allObjects = [];

    allObjects.addAll(routes);

    if (showAllStartPoints) {
      final startPointPlacemarks = startPoints.map((routePoint) {
        return PlacemarkMapObject(
          opacity: 1,
          mapId: MapObjectId('start_${routePoint.routeId}'),
          point: routePoint.point,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage(
                'assets/icons/location.png',
              ),
              scale: 0.3,
            ),
          ),
        );
      }).toList();

      final clusterCollection = ClusterizedPlacemarkCollection(
        mapId: const MapObjectId('start_points_cluster'),
        placemarks: startPointPlacemarks,
        radius: 60,
        minZoom: 10,
        onClusterAdded: (self, cluster) async {
          return cluster.copyWith(
            appearance: PlacemarkMapObject(
              mapId: cluster.appearance.mapId,
              point: cluster.appearance.point,
              opacity: 0.9,
              text: PlacemarkText(
                text: cluster.size.toString(),
                style: PlacemarkTextStyle(color: Colors.white),
              ),
              icon: PlacemarkIcon.single(
                PlacemarkIconStyle(
                  image: BitmapDescriptor.fromAssetImage(
                    'assets/icons/cluster.png',
                  ),

                  scale: 0.1,
                ),
              ),
            ),
          );
        },
        onClusterTap: (self, cluster) {},
      );

      allObjects.add(clusterCollection);
    } else if (selectedRouteId != null) {
      final startPoint = selectedStartPoint;
      if (startPoint != null) {
        allObjects.add(
          PlacemarkMapObject(
            opacity: 1,
            mapId: const MapObjectId('selected_start'),
            point: startPoint,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage(
                  'assets/icons/location.png',
                ),
                scale: 0.3,
              ),
            ),
          ),
        );
      }

      final endPoint = selectedEndPoint;
      if (endPoint != null) {
        allObjects.add(
          PlacemarkMapObject(
            opacity: 1,
            mapId: const MapObjectId('selected_end'),
            point: endPoint,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage(
                  'assets/icons/location.png',
                ),
                scale: 0.3,
              ),
            ),
          ),
        );
      }

      final wayPointPlacemarks = selectedWayPoints.map((point) {
        return PlacemarkMapObject(
          opacity: 1,
          mapId: MapObjectId('waypoint_${point.latitude}_${point.longitude}'),
          point: point,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage('assets/icons/point.png'),
              scale: 0.3,
            ),
          ),
        );
      }).toList();

      allObjects.addAll(wayPointPlacemarks);
    }

    return allObjects;
  }
}

class MapStateNotifier extends StateNotifier<MapState> {
  MapStateNotifier() : super(MapState());

  Future<void> createRoute(WidgetRef ref) async {
    try {
      state = state.copyWith(isLoading: true);
      final routeRepository = ref.read(routeRepositoryProvider);
      final routePointRepository = ref.read(routePointRepositoryProvider);
      final tipRepository = ref.read(tipRepositoryProvider);
      final creator = ref.read(userNotifierProvider).user;
      final routeInfo = ref.read(routeBuilderNotifierProvider);

      if (creator == null) return;
      final route = await routeRepository.createRoute(
        creatorId: creator.id,
        name: routeInfo.name!,
        description: routeInfo.description!,
        travelDuration: routeInfo.travelDuration!,
        isTaken: false,
      );
      await routePointRepository.createRoutePoint(
        routeId: route.id,
        latitude: routeInfo.startPoint!.latitude,
        longitude: routeInfo.startPoint!.longitude,
        order: 0,
        type: 'start',
      );

      if (routeInfo.photos != null && routeInfo.photos!.isNotEmpty) {
        final List<File> files = routeInfo.photos!
            .map((path) => File(path))
            .toList();
        await routeRepository.updateRoutePhotos(files: files, id: route.id);
      }
      if (routeInfo.wayPoints != null && routeInfo.wayPoints!.isNotEmpty) {
        for (int i = 0; i < routeInfo.wayPoints!.length; i++) {
          final point = routeInfo.wayPoints![i];
          await routePointRepository.createRoutePoint(
            routeId: route.id,
            latitude: point.latitude,
            longitude: point.longitude,
            order: i + 1,
            type: 'waypoint',
          );
        }
      }

      await routePointRepository.createRoutePoint(
        routeId: route.id,
        latitude: routeInfo.endPoint!.latitude,
        longitude: routeInfo.endPoint!.longitude,
        order: routeInfo.wayPoints!.length + 1,
        type: 'end',
      );
      if (routeInfo.tips != null && routeInfo.tips!.isNotEmpty) {
        for (int i = 0; i < routeInfo.tips!.length; i++) {
          final tip = routeInfo.tips![i];
          await tipRepository.addTip(routeId: route.id, text: tip.description);
        }
      }

      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint(e.toString());
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadStartPoints(WidgetRef ref) async {
    try {
      state = state.copyWith(isLoading: true);

      final allPoints = await ref
          .read(routePointRepositoryProvider)
          .getAllPoints();

      final routePoints = allPoints
          .map(
            (p) => RoutePointsModel(
              routeId: p.routeId,
              type: p.type,
              order: p.order,
              id: p.id,
              latitude: p.latitude,
              longitude: p.longitude,
              createdAt: p.createdAt,
            ),
          )
          .toList();

      state = state.copyWith(
        allRoutePoints: routePoints,
        selectedRouteId: null,
        showAllStartPoints: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadRouteByStartPoint(WidgetRef ref, String routeId) async {
    try {
      state = state.copyWith(
        isLoading: true,
        selectedRouteId: routeId,
        showAllStartPoints: false,
      );

      final start = state.selectedStartPoint;
      final end = state.selectedEndPoint;
      if (start != null && end != null) {
        await ref.read(yandexMapServiceProvider).buildPedestrianRoute(ref);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearPastPolilynes() {
    state = state.copyWith(routes: []);
  }

  void setError(String error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void setTappedPoint(String tappedRouteId) {
    state = state.copyWith(tappedRouteId: tappedRouteId);
  }

  void clearTappedPoint() {
    state = state.copyWith(tappedRouteId: null, showAllStartPoints: true);
  }

  void rebuildRoute(WidgetRef ref) async {
    await ref.read(yandexMapServiceProvider).buildPedestrianRoute(ref);
  }

  void setPickedRoute(RouteModel route) {
    state = state.copyWith(pickedRoute: route, selectedRouteId: route.id);
  }

  void clearPickedRoute() {
    state = state.copyWith(pickedRoute: null);
  }
}
