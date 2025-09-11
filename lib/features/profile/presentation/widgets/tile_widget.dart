import 'package:flutter/material.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';

class TileWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double width;
  final IconData icon;
  final Function()? onTap;
  const TileWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.width,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        leading: Container(
          height: 45,
          width: width,
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Center(child: Icon(icon)),
          ),
        ),
        title: Text(title, style: AppTheme.bodyMedium),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: AppTheme.bodySmall.copyWith(color: Colors.grey),
              )
            : null,
      ),
    );
  }
}
