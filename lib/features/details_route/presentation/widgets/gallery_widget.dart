import 'package:flutter/material.dart';

class GalleryWidget extends StatelessWidget {
  const GalleryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Галерея',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            height: 130,
            width: 130,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), color: Colors.black),
          ),
        ),
      ],
    );
  }
}
