import 'package:flutter/material.dart';

class CategoriesBar extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int selected;
  final Function(int) onSelect;
  const CategoriesBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 16),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = index == selected;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat['icon'], color: isActive ? Colors.black : Colors.grey),
                SizedBox(height: 4),
                Text(
                  cat['label'],
                  style: TextStyle(
                    color: isActive ? Colors.black : Colors.grey,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
