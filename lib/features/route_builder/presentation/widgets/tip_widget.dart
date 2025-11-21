import 'package:flutter/material.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';

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
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryLightColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: AppTheme.primaryLightColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tipText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            if (onPressed != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: Colors.grey[600],
          ),
          onPressed: onPressed,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
        ),
      ],
          ],
        ),
      ),
    );
  }
}
