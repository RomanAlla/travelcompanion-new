import 'dart:async';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/error/error_handler.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/features/details_route/presentation/screens/route_description_content.dart';
import 'package:travelcompanion/features/routes/data/models/interesting_route_points_model.dart';
import 'package:travelcompanion/features/routes/data/models/route_model.dart';
import 'package:travelcompanion/features/routes/presentation/providers/interesting_route_points_repository_provider.dart';
import 'package:travelcompanion/features/routes/presentation/providers/route_details_provider.dart';
import 'package:travelcompanion/features/routes/presentation/providers/route_point_repository_provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

@RoutePage()
class MapWatchModeScreen extends ConsumerStatefulWidget {
  final InterestingRoutePointsModel? point;
  const MapWatchModeScreen({super.key, this.point});

  @override
  ConsumerState<MapWatchModeScreen> createState() => _MapChangeModeState();
}

class _MapChangeModeState extends ConsumerState<MapWatchModeScreen> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final Completer<YandexMapController> _mapControllerCompleter = Completer();
  final List<RouteModel> points = [];
  final List<MapObject> mapObjects = [];
  RouteModel? selectedRoute;
  List<InterestingRoutePointsModel> selectedRoutePoints = [];
  bool _showInstruction = true;
  double _instructionOffset = -0.2;
  double _instructionOpacity = 0.0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAllPoints();
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          _instructionOffset = 0.0;
          _instructionOpacity = 1.0;
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> getAllPoints() async {
    try {
      final rep = ref.read(routePointRepositoryProvider);
      final points = await rep.getAllPoints();
      setState(() {
        mapObjects.clear();
        mapObjects.addAll(
          points
              .where(
                (route) => route.latitude != null && route.longitude != null,
              )
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
                  onTap: (self, point) => onRouteMarkerTap(route),
                ),
              )
              .toList(),
        );
      });
    } catch (e) {
      ErrorHandler.getErrorMessage(e);
    }
  }

  Future<void> onRouteMarkerTap(RouteModel route) async {
    final pointsRep = ref.read(interestingRoutePointsRepositoryProvider);
    final points = await pointsRep.getInterestingPointsByRouteId(route.id);

    setState(() {
      mapObjects.removeWhere((obj) => obj.mapId.value.startsWith('interest_'));

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
                    image: BitmapDescriptor.fromAssetImage('assets/star.png'),
                    scale: 1.0,
                  ),
                ),
              ),
            )
            .toList(),
      );
    });

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.05,
          minChildSize: 0.05,
          maxChildSize: 0.9,
          snap: true,
          snapSizes: const [0.05, 0.9],
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, _) {
                final detailsAsync = ref.watch(routeDetailsProvider(route));
                return detailsAsync.when(
                  data: (details) => Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          RouteDescriptionContent(
                            creator: details.creator,
                            route: route,
                            commentsCount: details.commentsCount,
                            averageRating: details.averageRating,
                            userRoutesCount: details.userRoutesCount,
                            averageUserRoutesRating:
                                details.averageUserRoutesRating,
                            commentsList: details.commentsList,
                            myItems: details.myItems,
                            currentIndex: details.currentIndex,
                          ),
                        ],
                      ),
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Ошибка: $e')),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                );
              },
            );
          },
        );
      },
    );
    _sheetController.addListener(() {
      if (_sheetController.size <= 0.051) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (controller) {
              _mapControllerCompleter.complete(controller);
            },
            mapObjects: mapObjects,
            onMapTap: (point) {
              setState(() {
                mapObjects.removeWhere(
                  (obj) => obj.mapId.value.startsWith('interest_'),
                );
              });
            },
          ),
          if (_showInstruction)
            Positioned(
              top: 32,
              left: 24,
              right: 24,
              child: AnimatedSlide(
                offset: Offset(0, _instructionOffset),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  opacity: _instructionOpacity,
                  duration: const Duration(milliseconds: 600),
                  child: GestureDetector(
                    onTap: () => setState(() => _showInstruction = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.touch_app,
                            color: AppTheme.primaryLightColor,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'Нажмите на метку маршрута, чтобы увидеть детали маршрута, а так же интересные места этого пути',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _showInstruction = false),
                            child: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
