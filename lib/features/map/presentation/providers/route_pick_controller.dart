import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/map/domain/enums/route_pick_state.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class RoutePickController extends StateNotifier<RoutePickState> {
  RoutePickController() : super(RoutePickState.none);

  Point? startPoint;
  Point? endPoint;

  void selectPoint(Point point) {
    if (startPoint == null) {
      startPoint = point;
      state = RoutePickState.startPicked;
    } else if (endPoint == null) {
      endPoint = point;
      state = RoutePickState.bothPicked;
    } else {
      startPoint = point;
      endPoint = null;
      state = RoutePickState.startPicked;
    }
  }

  void reset() {
    startPoint = null;
    endPoint = null;
    state = RoutePickState.none;
  }
}

final routePickControllerProvider =
    StateNotifierProvider<RoutePickController, RoutePickState>(
      (ref) => RoutePickController(),
    );
