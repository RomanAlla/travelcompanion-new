import 'package:flutter/material.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';

class QuitButtonWidget extends StatelessWidget {
  final void Function()? onPressed;
  const QuitButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        backgroundColor: AppTheme.primaryLightColor,
      ),
      onPressed: onPressed,
      child: Text(
        'Выйти',
        style: AppTheme.bodyMediumBold.copyWith(color: Colors.white),
      ),
    );
  }
}
