import 'package:flutter/material.dart';

class TipsWidget extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  const TipsWidget({
    super.key,
    required this.label,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline),
            SizedBox(width: 10),
            Expanded(child: Text(label, style: TextStyle(fontSize: 16))),
          ],
        ),
      ],
    );
  }
}
