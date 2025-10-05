import 'package:flutter/material.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Список избранного пуст',
            style: AppTheme.titleMediumBold.copyWith(color: AppTheme.grey700),
          ),
          const SizedBox(height: 8),
          Text(
            'Сохраняйте понравившиеся маршруты,\nчтобы вернуться к ним позже',
            textAlign: TextAlign.center,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.grey600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.explore),
            label: Text(
              'Найти маршруты',
              style: AppTheme.bodyMediumBold.copyWith(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryLightColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
