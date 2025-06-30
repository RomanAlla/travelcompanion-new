import 'package:flutter/material.dart';

class RoutePointsWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  const RoutePointsWidget(
      {super.key,
      required this.icon,
      required this.label,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon)),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 15),
                )
              ],
            )
          ],
        )
      ],
    );
  }
}
