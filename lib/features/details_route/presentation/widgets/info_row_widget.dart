import 'package:flutter/material.dart';

class InfoIconText extends StatelessWidget {
  final IconData icon;
  final String label;
  const InfoIconText({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Color(0xFFFF385C)),
        ),
        SizedBox(height: 6),
        SizedBox(
          height: 36,
          child: Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
