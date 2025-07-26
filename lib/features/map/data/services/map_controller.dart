import 'package:travelcompanion/features/routes/data/models/interesting_route_points_model.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MyMapController {
  final List<MapObject> mapObjects = [];

  void addRouteMarkers(
    List<RouteModel> routes,
    void Function(RouteModel) onTap,
  ) {
    mapObjects.addAll(
      routes
          .where((route) => route.latitude != null && route.longitude != null)
          .map(
            (route) => PlacemarkMapObject(
              mapId: MapObjectId('route_${route.id}'),
              point: Point(
                latitude: route.latitude!,
                longitude: route.longitude!,
              ),
              icon: PlacemarkIcon.single(
                PlacemarkIconStyle(
                  image: BitmapDescriptor.fromAssetImage(
                    'assets/icons/location.png',
                  ),
                  scale: 0.3,
                ),
              ),
              onTap: (self, point) => onTap(route),
            ),
          ),
    );
  }

  void addInterestingPoints(List<InterestingRoutePointsModel> points) {
    mapObjects.addAll(
      points
          .where((point) => point.latitude != null && point.longitude != null)
          .map(
            (point) => PlacemarkMapObject(
              mapId: MapObjectId('interest_${point.id}'),
              point: Point(
                latitude: point.latitude!,
                longitude: point.longitude!,
              ),
              icon: PlacemarkIcon.single(
                PlacemarkIconStyle(
                  image: BitmapDescriptor.fromAssetImage('assets/point.png'),
                  scale: 0.2,
                ),
              ),
            ),
          ),
    );
  }

  void removeInterestingPoints() {
    mapObjects.removeWhere((obj) => obj.mapId.value.startsWith('interest_'));
  }

  void clearAll() {
    mapObjects.clear();
  }
}
