import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/router/router.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/way_points_provider.dart';
import 'package:travelcompanion/features/map/domain/enums/map_mode.dart';

class RoutePointsWidget extends ConsumerWidget {
  final String routeId;
  const RoutePointsWidget(this.routeId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointsAsyncValue = ref.watch(wayPointsListProvider(routeId));
    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Интересные точки маршрута',
                  style: AppTheme.bodyMediumBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          pointsAsyncValue.when(
            data: (pointsList) {
              if (pointsList.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.lightBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 24,
                          color: AppTheme.primaryLightColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Нет интересных точек',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: pointsList
                    .map(
                      (point) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C5CE7).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: AppTheme.primaryLightColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            '${point.latitude}, ${point.longitude}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                          trailing: IconButton(
                            onPressed: () {
                              context.router.push(
                                MapRoute(mode: MapMode.viewAll),
                              );
                            },
                            icon: Icon(
                              Icons.arrow_circle_right,
                              color: AppTheme.primaryLightColor,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
