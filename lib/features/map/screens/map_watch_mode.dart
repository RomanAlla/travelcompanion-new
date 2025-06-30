import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:travelcompanion/features/map/data/map_state.dart'
    hide MapController;
import 'package:travelcompanion/features/routes/data/models/route_model.dart';
import 'package:travelcompanion/features/routes/presentation/providers/route_point_repository_provider.dart';

@RoutePage()
class MapWatchModeScreen extends ConsumerStatefulWidget {
  const MapWatchModeScreen({super.key});

  @override
  ConsumerState<MapWatchModeScreen> createState() => _MapChangeModeState();
}

class _MapChangeModeState extends ConsumerState<MapWatchModeScreen> {
  late final MapController _mapController;
  final List<RouteModel> points = [];

  @override
  void initState() {
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAllPoints();
    });
    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> getAllPoints() async {
    try {
      final rep = ref.read(routePointRepositoryProvider);
      final points = await rep.getAllPoints();

      final markers = points
          .where((point) => point.latitude != null && point.longitude != null)
          .map(
            (point) => Marker(
              point: LatLng(point.latitude!, point.longitude!),
              width: 40,
              height: 40,
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          )
          .toList();

      ref.read(mapStateProvider.notifier).updateMarks(markers);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapStateProvider);

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,

        options: MapOptions(
          initialCenter: LatLng(55.755793, 37.617134),
          initialZoom: 6,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.travelcompanion',
          ),
          MarkerLayer(markers: mapState.placemarks),
        ],
      ),
    );
  }
}
