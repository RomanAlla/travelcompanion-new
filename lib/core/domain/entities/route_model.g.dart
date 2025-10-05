// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteModel _$RouteModelFromJson(Map<String, dynamic> json) => RouteModel(
  creator: json['creator'] == null
      ? null
      : UserModel.fromJson(json['creator'] as Map<String, dynamic>),
  creatorId: json['creator_id'] as String,
  travelDuration: (json['travel_duration'] as num?)?.toInt(),
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  photoUrls:
      (json['photo_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$RouteModelToJson(RouteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creator_id': instance.creatorId,
      'creator': instance.creator,
      'name': instance.name,
      'description': instance.description,
      'travel_duration': instance.travelDuration,
      'photo_urls': instance.photoUrls,
      'created_at': instance.createdAt.toIso8601String(),
    };
