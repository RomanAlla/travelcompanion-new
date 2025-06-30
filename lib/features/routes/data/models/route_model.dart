import 'package:travelcompanion/features/auth/data/models/user_model.dart';

class RouteModel {
  final String id;
  final String creatorId;
  final UserModel? creator;
  final String name;
  final String? description;
  final List<String> photoUrls;
  final DateTime createdAt;
  final String routeType;
  final double? longitude;
  final double? latitude;

  RouteModel({
    this.creator,
    required this.id,
    required this.creatorId,
    required this.name,
    this.description,
    this.photoUrls = const [],
    required this.routeType,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'creator_id': creatorId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'photo_urls': photoUrls,
      'route_type': routeType,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as String,
      photoUrls:
          (json['photo_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      creatorId: json['creator_id'] as String,
      creator: json['creator'] != null
          ? UserModel.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
      name: json['name'] as String? ?? '',

      description: json['description'] as String? ?? '0',
      latitude: json['latitude'] as double?,
      routeType: json['route_type'] as String? ?? '',
      longitude: json['longitude'] as double?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
