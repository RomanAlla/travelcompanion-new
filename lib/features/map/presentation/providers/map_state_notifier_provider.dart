import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/map/data/services/map_state_notifier.dart';

final mapStateNotifierProvider =
    StateNotifierProvider<MapStateNotifier, MapState>((ref) {
      return MapStateNotifier();
    });
