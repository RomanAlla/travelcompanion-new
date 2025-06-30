import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
@RoutePage()
class TravelsScreen extends StatelessWidget {
  const TravelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: const Center(
        child: Text('Travels'),
      ),
    );
  }
}
