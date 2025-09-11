import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapDisplayWidget extends StatefulWidget {
  final Marker? marker;
  final Function(LatLng)? onPointSelected;

  const MapDisplayWidget({super.key, this.marker, this.onPointSelected});

  @override
  State<MapDisplayWidget> createState() => _MapDisplayWidgetState();
}

class _MapDisplayWidgetState extends State<MapDisplayWidget> {
  late final MapController _mapController;
  LatLng? point;

  @override
  void initState() {
    _mapController = MapController();
    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _centerOnPoint(LatLng point) {
    _mapController.move(point, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Расположение',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  // final result = await context.router.push<LatLng>(
                  //   MapChangeModeRoute(),
                  // );
                  // if (result != null && widget.onPointSelected != null) {
                  //   widget.onPointSelected!(result);
                  //   setState(() {
                  //     point = result;
                  //   });
                  //   _centerOnPoint(result);
                  // }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: point ?? const LatLng(53, 42),
                          initialZoom: 6,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        mapController: _mapController,
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.travelcompanion',
                          ),
                          if (widget.marker != null)
                            MarkerLayer(markers: [widget.marker!]),
                        ],
                      ),
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.1),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.touch_app,
                                  size: 32,
                                  color: Colors.white,
                                ),
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
            ),
          ],
        ),
      ),
    );
  }
}
