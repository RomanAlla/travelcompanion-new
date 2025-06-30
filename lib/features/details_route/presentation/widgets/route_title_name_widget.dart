import 'package:flutter/material.dart';

class RouteTitleNameWidget extends StatelessWidget {
  final String text;
  const RouteTitleNameWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 23, fontWeight: FontWeight.w400),
      textAlign: TextAlign.center,
    );
  }
}
