import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/map/presentation/providers/yandex_map_service_provider.dart';
import 'package:travelcompanion/features/route_builder/data/models/route_point_model.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_point_repository_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_repository_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/tip_repository_provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapState {
  final List<RoutePointsModel> allRoutePoints; // Все точки всех маршрутов
  final List<PolylineMapObject> routes; // Маршруты
  final String? error;
  final bool isLoading;
  final bool showAllStartPoints;
  final String? selectedRouteId; // ID выбранного маршрута

  const MapState({
    this.error,
    this.allRoutePoints = const [],
    this.routes = const [],
    this.isLoading = false,
    this.showAllStartPoints = true,
    this.selectedRouteId,
  });

  MapState copyWith({
    List<RoutePointsModel>? allRoutePoints,
    List<PolylineMapObject>? routes,
    bool? isLoading,
    String? error,
    bool? showAllStartPoints,
    String? selectedRouteId,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      allRoutePoints: allRoutePoints ?? this.allRoutePoints,
      routes: routes ?? this.routes,
      error: error ?? this.error,
      showAllStartPoints: showAllStartPoints ?? this.showAllStartPoints,
      selectedRouteId: selectedRouteId ?? this.selectedRouteId,
    );
  }

  // Геттеры для удобства
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

    // Добавляем маршруты
    allObjects.addAll(routes);

    // Режим показа всех стартовых точек
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

      // Кластеризация только стартовых точек
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
              opacity: 1,
              icon: PlacemarkIcon.single(
                PlacemarkIconStyle(
                  image: BitmapDescriptor.fromAssetImage(
                    'assets/icons/cluster.png',
                  ),
                  scale: 0.4,
                ),
              ),
            ),
          );
        },
        onClusterTap: (self, cluster) {
          debugPrint('Tapped cluster with ${cluster.placemarks.length} items');
        },
      );

      allObjects.add(clusterCollection);
    }
    // Режим показа конкретного маршрута
    else if (selectedRouteId != null) {
      // Стартовая точка
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

      // Конечная точка
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

      // Промежуточные точки (без кластеризации!)
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
      final creator = ref.read(authProvider).user;
      final routeInfo = ref.read(routeBuilderNotifierProvider);

      if (creator == null) return;
      final route = await ref
          .read(routeRepositoryProvider)
          .createRoute(
            creatorId: creator.id,
            name: routeInfo.name!,
            description: routeInfo.description!,
            travelDuration: routeInfo.travelDuration!,
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
          await tipRepository.createTip(
            routeId: route.id,
            description: tip.description,
          );
        }
      }

      state = state.copyWith(isLoading: false);
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
        allRoutePoints: routePoints, // Сохраняем все точки
        selectedRouteId: null, // Сбрасываем выбранный маршрут
        showAllStartPoints: true, // Показываем все стартовые точки
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
      final waypoints = state.selectedWayPoints;

      if (start != null && end != null) {
        await ref.read(yandexMapServiceProvider).buildPedestrianRoute(ref);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setError(String error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void rebuildRoute(WidgetRef ref) async {
    await ref.read(yandexMapServiceProvider).buildPedestrianRoute(ref);
  }
}
