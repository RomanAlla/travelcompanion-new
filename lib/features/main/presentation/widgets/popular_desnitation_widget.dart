import 'package:flutter/material.dart';

class PopularDesnitationWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  const PopularDesnitationWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
