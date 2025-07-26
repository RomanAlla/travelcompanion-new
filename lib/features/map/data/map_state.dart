import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

final mapStateProvider = StateNotifierProvider<MapController, MapState>((ref) {
  return MapController();
});

final mapControllerProvider = Provider<MapController>((ref) {
  return ref.watch(mapStateProvider.notifier);
});

class MapController extends StateNotifier<MapState> {
  MapController() : super(MapState());

  void addMark(PlacemarkMapObject marker) {
    final updatedPlacemarks = List<PlacemarkMapObject>.from(state.placemarks)
      ..add(marker);
    state = state.copyWith(placemarks: updatedPlacemarks);
  }

  void updateMarks(List<PlacemarkMapObject> markers) {
    final updatedPlacemarsk = List<PlacemarkMapObject>.from(state.placemarks)
      ..addAll(markers);
    state = state.copyWith(placemarks: updatedPlacemarsk);
  }

  void deleteMark(PlacemarkMapObject marker) {
    final updatedPlacemarks = List<PlacemarkMapObject>.from(state.placemarks)
      ..add(marker);
    state = state.copyWith(placemarks: updatedPlacemarks);
  }

  void clearMarks() {
    state = state.copyWith(placemarks: []);
  }
}

class MapState {
  final LatLng? initialLocation;
  final LatLng? currentLocation;
  final List<PlacemarkMapObject> placemarks;
  final MapMode mapMode;

  MapState({
    this.placemarks = const [],
    this.mapMode = MapMode.route,
    this.initialLocation,
    this.currentLocation,
  });

  MapState copyWith({
    ValueGetter<LatLng?>? initialLocation,
    ValueGetter<LatLng?>? currentLocation,
    List<PlacemarkMapObject>? placemarks,
    MapMode? mapMode,
  }) {
    return MapState(
      initialLocation: initialLocation != null
          ? initialLocation()
          : this.initialLocation,
      currentLocation: currentLocation != null
          ? currentLocation()
          : this.currentLocation,
      placemarks: placemarks ?? this.placemarks,
      mapMode: mapMode ?? this.mapMode,
    );
  }
}

enum MapMode { normal, search, route }
