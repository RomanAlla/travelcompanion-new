import 'package:flutter/material.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/core/domain/utils/string_utils.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/tile_widget.dart';

class TripsColumnWidget extends StatelessWidget {
  final int plannedCount;
  const TripsColumnWidget({super.key, required this.plannedCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Маршруты', style: AppTheme.titleSmallBold),
        SizedBox(height: 8),
        TileWidget(
          title: 'Запланированные',
          subtitle: StringUtils.pluralizeRoute(plannedCount),
          width: 45,
          icon: Icons.calendar_today,
        ),
      ],
    );
  }
}
