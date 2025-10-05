import 'package:json_annotation/json_annotation.dart';
import 'package:travelcompanion/core/domain/entities/user_model.dart';

part 'route_model.g.dart';

@JsonSerializable()
class RouteModel {
  final String id;
  @JsonKey(name: 'creator_id')
  final String creatorId;
  final UserModel? creator;
  final String name;
  final String? description;
  @JsonKey(name: 'travel_duration')
  final int? travelDuration;
  @JsonKey(name: 'photo_urls')
  final List<String> photoUrls;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  RouteModel({
    this.creator,
    required this.creatorId,
    required this.travelDuration,
    required this.id,
    required this.name,
    this.description,
    this.photoUrls = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => _$RouteModelToJson(this);

  factory RouteModel.fromJson(Map<String, dynamic> json) =>
      _$RouteModelFromJson(json);
}
