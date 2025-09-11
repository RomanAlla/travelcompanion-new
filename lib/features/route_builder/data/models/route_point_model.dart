import 'package:json_annotation/json_annotation.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
part 'route_point_model.g.dart';

@JsonSerializable(explicitToJson: true)
class RoutePointsModel {
  final String id;
  @JsonKey(name: 'route_id')
  final String routeId;
  final double latitude;
  final double longitude;
  final int order;
  final String type;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  RoutePointsModel({
    required this.id,
    required this.routeId,
    required this.latitude,
    required this.longitude,
    required this.order,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => _$RoutePointsModelToJson(this);

  factory RoutePointsModel.fromJson(Map<String, dynamic> json) =>
      _$RoutePointsModelFromJson(json);
}

extension RoutePointsModelExtensions on RoutePointsModel {
  Point get point {
    return Point(latitude: latitude, longitude: longitude);
  }
}
