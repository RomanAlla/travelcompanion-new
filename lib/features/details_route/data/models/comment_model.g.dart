// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
  routeId: json['route_id'] as String,
  id: json['id'] as String,
  creatorId: json['creator_id'] as String,
  text: json['text'] as String,
  rating: (json['rating'] as num).toInt(),
  images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
  createdAt: DateTime.parse(json['created_at'] as String),
  creator: json['creator'] == null
      ? null
      : UserModel.fromJson(json['creator'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creator_id': instance.creatorId,
      'route_id': instance.routeId,
      'text': instance.text,
      'rating': instance.rating,
      'images': instance.images,
      'created_at': instance.createdAt.toIso8601String(),
      'creator': instance.creator,
    };
