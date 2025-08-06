import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:travelcompanion/core/router/router.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';

class MapContainer extends StatefulWidget {
  final RouteModel route;

  const MapContainer({super.key, required this.route});

  @override
  State<MapContainer> createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(
        LatLng(widget.route.latitude!, widget.route.longitude!),
        13,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final point = LatLng(widget.route.latitude!, widget.route.longitude!);
    return Container(
      height: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        // onTap: () => context.router.push(MapScreenRoute(point: point)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(55.7558, 37.6173),
                  initialZoom: 13,
                ),
                mapController: _mapController,
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.travelcompanion',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          widget.route.latitude!,
                          widget.route.longitude!,
                        ),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app, size: 32, color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          'Нажмите, чтобы открыть карту',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
