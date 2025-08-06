import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/map/domain/enums/map_mode.dart';
import 'package:travelcompanion/features/routes/data/models/route_point_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

final mapControllerProvider = Provider<MapController>((ref) {
  return MapController();
});

class MapController extends StateNotifier<List<RoutePointModel>> {
  MapController() : super([]);

  PlacemarkMapObject? onMapTap(
    Point point,
    MapMode mode,
    List<PlacemarkMapObject> selectedPoints,
  ) {
    if (mode == MapMode.pickPoints) {
      if (selectedPoints.length < 2) {
        final marker = PlacemarkMapObject(
          mapId: MapObjectId('picked_${selectedPoints.length}'),
          point: point,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage(
                'assets/icons/location.png',
              ),
              scale: 0.3,
            ),
          ),
        );

        return marker;
      }
    }
    return null;
  }

  void clearMarks() {
    state = [];
  }
}
