import 'package:flutter/material.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';

class ActionButtonWidget extends StatefulWidget {
  final void Function()? onPressed;
  final Color? backgroundColor;
  final String text;
  const ActionButtonWidget({
    super.key,
    required this.onPressed,
    required this.backgroundColor,
    required this.text,
  });

  @override
  State<ActionButtonWidget> createState() => _ActionButtonWidgetState();
}

class _ActionButtonWidgetState extends State<ActionButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            widget.text,
            style: AppTheme.titleSmallBold.copyWith(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
