import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/core/domain/entities/route_model.dart';

class RouteDescriptionWidget extends ConsumerWidget {
  final RouteModel route;
  const RouteDescriptionWidget({super.key, required this.route});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLightColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: AppTheme.primaryLightColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Описание',
                  style: AppTheme.titleSmallBold.copyWith(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              route.description ?? 'Нет описания',
              style: AppTheme.bodyMedium.copyWith(
                height: 1.5,
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
