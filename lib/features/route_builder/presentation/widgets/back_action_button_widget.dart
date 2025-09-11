import 'package:flutter/material.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';

class BackActionButtonWidget extends StatelessWidget {
  final void Function()? onPressed;
  final String label;

  const BackActionButtonWidget({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppTheme.lightBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: AppTheme.bodyMediumBold,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
