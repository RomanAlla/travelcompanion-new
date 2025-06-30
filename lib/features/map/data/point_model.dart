import 'package:latlong2/latlong.dart';

class PointModel {
  final LatLng point;

  PointModel({required this.point});

  PointModel copyWith({LatLng? point}) {
    return PointModel(point: point ?? this.point);
  }
}
