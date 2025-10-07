import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';

class ErrorWidget extends StatelessWidget {
  const ErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('Ошибка загрузки стран', style: AppTheme.bodyMedium)],
      ),
    );
  }
}
