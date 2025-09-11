import 'package:flutter/material.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/tile_widget.dart';

class TripsColumnWidget extends StatelessWidget {
  const TripsColumnWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Маршруты', style: AppTheme.titleSmallBold),
        SizedBox(height: 8),
        TileWidget(
          title: 'Пройденные',
          subtitle: '4 маршрута',
          width: 45,
          icon: Icons.map,
        ),
        SizedBox(height: 5),
        TileWidget(
          title: 'Запланированные',
          subtitle: '3 маршрута',
          width: 45,
          icon: Icons.calendar_today,
        ),
      ],
    );
  }
}
