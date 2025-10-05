import 'package:json_annotation/json_annotation.dart';
import 'package:travelcompanion/core/domain/entities/user_model.dart';
part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  final String id;
  @JsonKey(name: 'creator_id')
  final String creatorId;
  @JsonKey(name: 'route_id')
  final String routeId;
  final String text;
  final int rating;
  final List<String>? images;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'creator')
  final UserModel? creator;

  CommentModel({
    required this.routeId,
    required this.id,
    required this.creatorId,
    required this.text,
    required this.rating,
    this.images,
    required this.createdAt,
    this.creator,
  });
  Map<String, dynamic> toJson() => _$CommentModelToJson(this);

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);
}
