import 'package:flutter/material.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';

class TileWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double width;
  final IconData icon;
  final Function()? onTap;
  final bool isDestructive;

  const TileWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.width,
    required this.icon,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isDestructive
        ? Colors.red.shade400
        : AppTheme.primaryLightColor;

    return Container(
          decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
          ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),
          ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.bodyMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? Colors.red.shade400
                              : Colors.black87,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                subtitle!,
                          style: AppTheme.bodyMini.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
