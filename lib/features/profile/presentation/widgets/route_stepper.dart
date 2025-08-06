import 'package:flutter/material.dart';

class RouteStepperNavigation extends StatelessWidget {
  final int currentIndex;
  final int totalSteps;
  final void Function(int index) onStepTapped;

  const RouteStepperNavigation({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final List<IconData> icons = [
      Icons.map_outlined,
      Icons.info_outline,
      Icons.photo_camera_outlined,
      Icons.place_outlined,
      Icons.lightbulb_outline,
      Icons.check_circle_outline,
    ];

    final List<String> labels = [
      "Выбор",
      "Инфо",
      "Фото",
      "Точки",
      "Советы",
      "Готово",
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(totalSteps, (index) {
          final bool isActive = index == currentIndex;
          return GestureDetector(
            onTap: () => onStepTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF6C5CE7).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icons[index],
                    color: isActive ? const Color(0xFF6C5CE7) : Colors.grey,
                    size: isActive ? 28 : 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? const Color(0xFF6C5CE7) : Colors.grey,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
