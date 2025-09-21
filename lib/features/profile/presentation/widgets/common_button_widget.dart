import 'package:flutter/material.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';

class CommonButtonWidget extends StatefulWidget {
  final void Function()? onPressed;
  final String text;
  const CommonButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  State<CommonButtonWidget> createState() => _CommonButtonWidgetState();
}

class _CommonButtonWidgetState extends State<CommonButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: widget.onPressed,

        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppTheme.lightGrey,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            widget.text,
            style: AppTheme.titleSmallBold.copyWith(color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
