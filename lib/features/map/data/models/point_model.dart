import 'package:yandex_mapkit/yandex_mapkit.dart';

class RoutePointModel {
  final Point point;
  final bool isSelected;
  final bool isStart;

  RoutePointModel({
    required this.point,
    this.isSelected = false,
    this.isStart = false,
  });

  RoutePointModel copyWith({Point? point, bool? isSelected, bool? isStart}) {
    return RoutePointModel(
      point: point ?? this.point,
      isSelected: isSelected ?? this.isSelected,
      isStart: isStart ?? this.isStart,
    );
  }
}
