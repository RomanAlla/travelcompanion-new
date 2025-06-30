// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TipModel _$TipModelFromJson(Map<String, dynamic> json) => TipModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  routeId: json['route_id'] as String,
);

Map<String, dynamic> _$TipModelToJson(TipModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'route_id': instance.routeId,
};
