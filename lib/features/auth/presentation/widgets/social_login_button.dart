import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blue[700], size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                overflow: TextOverflow.ellipsis,
                label,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
