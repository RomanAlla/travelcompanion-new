import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:travelcompanion/features/map/data/map_state.dart'
    hide MapController;

@RoutePage()
class MapChangeModeScreen extends ConsumerStatefulWidget {
  const MapChangeModeScreen({super.key});

  @override
  ConsumerState<MapChangeModeScreen> createState() => _MapChangeModeState();
}

class _MapChangeModeState extends ConsumerState<MapChangeModeScreen>
    with TickerProviderStateMixin {
  late final _animatedMapController = AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
    curve: Curves.easeInOutCubic,
  );
  LatLng? selectedPoint;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapControllerProvider).clearMarks();
    });
  }

  @override
  void dispose() {
    _animatedMapController.dispose();

    super.dispose();
  }

  void addMark(LatLng point) {
    setState(() {
      selectedPoint = point;
    });
    ref.read(mapControllerProvider).clearMarks();
    ref
        .read(mapControllerProvider)
        .addMark(
          Marker(
            point: point,
            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите точку на карте'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                selectedPoint = null;
              });
              ref.read(mapControllerProvider).clearMarks();
            },
            tooltip: 'Очистить точку',
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (selectedPoint != null) {
                    context.router.pop(selectedPoint);
                  } else {
                    context.router.pop();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Сохранить',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _animatedMapController.mapController,
        options: MapOptions(
          onTap: (tapPosition, point) {
            addMark(point);
            Future.delayed(const Duration(milliseconds: 100), () {
              _animatedMapController.mapController.move(point, 15);
            });
          },
          initialCenter: const LatLng(55.755793, 37.617134),
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
