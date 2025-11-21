import 'package:flutter/material.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';

class AuthButtonWidget extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final bool isLoading;

  const AuthButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLightColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else ...[
                  Text(
                    text,
                    style: AppTheme.bodyMediumBold.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
