import 'package:flutter/material.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';

class TipWidget extends StatelessWidget {
  final String tipText;
  final int i;
  final void Function()? onPressed;
  const TipWidget({
    super.key,
    required this.tipText,
    required this.i,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Совет ${i + 1}: $tipText', style: AppTheme.bodyMediumBold),
        TextButton(
          style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: WidgetStatePropertyAll(Size.zero),
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
            elevation: WidgetStatePropertyAll(0),
          ),
          onPressed: onPressed,
          child: Text('Удалить', style: AppTheme.hintStyle),
        ),
        // Text('Удалить', style: AppTheme.hintStyle),
      ],
    );
  }
}
