// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutePointsModel _$RoutePointsModelFromJson(Map<String, dynamic> json) =>
    RoutePointsModel(
      id: json['id'] as String,
      routeId: json['route_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      order: (json['order'] as num).toInt(),
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RoutePointsModelToJson(RoutePointsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'route_id': instance.routeId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'order': instance.order,
      'type': instance.type,
      'created_at': instance.createdAt.toIso8601String(),
    };
