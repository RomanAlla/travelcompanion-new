import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/map/domain/enums/map_mode.dart';
import 'package:travelcompanion/features/map/domain/enums/route_pick_state.dart';
import 'package:travelcompanion/features/map/presentation/providers/map_state_notifier_provider.dart';
import 'package:travelcompanion/core/domain/entities/tip_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

final routeBuilderNotifierProvider =
    StateNotifierProvider<RouteBuilderNotifier, RouteForm>((ref) {
      return RouteBuilderNotifier();
    });

class RouteForm {
  final String? name;
  final String? description;
  final List<PolylineMapObject> routes;
  final Point? startPoint;
  final Point? endPoint;
  final int? travelDuration;
  final List<String>? photos;
  final List<Point>? wayPoints;
  final List<TipModel>? tips;
  final PointPickState status;

  RouteForm({
    this.routes = const [],
    this.startPoint,
    this.endPoint,
    this.name,
    this.description,
    this.travelDuration,
    this.photos = const [],
    this.wayPoints = const [],
    this.tips = const [],
    this.status = PointPickState.none,
  });

  RouteForm copyWith({
    String? name,
    String? description,
    List<PolylineMapObject>? routes,
    Point? startPoint,
    Point? endPoint,
    int? travelDuration,
    List<String>? photos,
    List<Point>? wayPoints,
    List<TipModel>? tips,
    PointPickState? status,
  }) {
    return RouteForm(
      name: name ?? this.name,
      description: description ?? this.description,
      travelDuration: travelDuration ?? this.travelDuration,
      photos: photos ?? this.photos,
      wayPoints: wayPoints ?? this.wayPoints,
      tips: tips ?? this.tips,
      routes: routes ?? this.routes,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      status: status ?? this.status,
    );
  }

  List<MapObject> get mapObjects {
    final List<MapObject> objects = [];
    for (int i = 0; i < wayPoints!.length; i++) {
      objects.add(
        PlacemarkMapObject(
          opacity: 1,
          mapId: MapObjectId('point_$i'),
          point: wayPoints![i],
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage('assets/icons/point.png'),
              scale: 0.3,
            ),
          ),
        ),
      );
    }
    if (startPoint != null) {
      objects.add(
        PlacemarkMapObject(
          opacity: 1,
          mapId: MapObjectId('start_${DateTime.now().microsecondsSinceEpoch}'),
          point: startPoint!,
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
    if (endPoint != null) {
      objects.add(
        PlacemarkMapObject(
          opacity: 1,
          mapId: MapObjectId('end_${DateTime.now().microsecondsSinceEpoch}'),
          point: endPoint!,
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
    objects.addAll(routes);
    return objects;
  }
}

class RouteBuilderNotifier extends StateNotifier<RouteForm> {
  RouteBuilderNotifier() : super(RouteForm());

  void addStartPoint(Point point) {
    state = state.copyWith(
      startPoint: point,
      status: PointPickState.startPicked,
    );
  }

  void handleTap(Point point, MapMode mode) {
    if (mode == MapMode.pickMainPoints) {
      if (state.status == PointPickState.none) {
        addStartPoint(point);
      } else if (state.status == PointPickState.startPicked) {
        addEndPoint(point);
      } else {
        clearAll();
      }
    } else if (mode == MapMode.pickWayPoints) {
      if (state.status == PointPickState.none) {
        addStartPoint(point);
      } else if (state.status == PointPickState.startPicked) {
        addEndPoint(point);
      } else {
        addWayPoint(point);
      }
    }
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void addEndPoint(Point point) {
    state = state.copyWith(endPoint: point, status: PointPickState.bothPicked);
  }

  void addWayPoint(Point point) {
    state = state.copyWith(wayPoints: [...state.wayPoints!, point]);
  }

  void deleteWayPoints(WidgetRef ref) {
    state = state.copyWith(wayPoints: const []);
    ref.read(mapStateNotifierProvider.notifier).rebuildRoute(ref);
  }

  void setRoutes(List<PolylineMapObject> routes) {
    state = state.copyWith(routes: routes);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setDuration(int duration) {
    state = state.copyWith(travelDuration: duration);
  }

  void setPhotos(List<String> photos) {
    state = state.copyWith(photos: photos);
  }

  void setWayPoints(List<Point> wayPoints) {
    state = state.copyWith(wayPoints: wayPoints);
  }

  void setTips(List<TipModel> tips) {
    state = state.copyWith(tips: tips);
  }

  void clearAll() {
    state = RouteForm();
  }
}
