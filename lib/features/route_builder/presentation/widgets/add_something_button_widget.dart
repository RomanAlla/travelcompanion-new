import 'package:flutter/material.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';

class AddSomethingButtonWidget extends StatelessWidget {
  final void Function()? onPressed;
  const AddSomethingButtonWidget({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 0,

      onPressed: onPressed,
      backgroundColor: AppTheme.primaryLightColor,
      child: Icon(Icons.add),
    );
  }
}
