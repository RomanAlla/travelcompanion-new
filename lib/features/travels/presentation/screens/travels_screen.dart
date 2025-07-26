import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

@RoutePage()
class TravelsScreen extends StatelessWidget {
  const TravelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.grey[50], body: YandexMap());
  }
}
