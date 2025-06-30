import 'package:json_annotation/json_annotation.dart';
part 'tip_model.g.dart';

@JsonSerializable()
class TipModel {
  final String id;
  final String name;
  final String description;
  @JsonKey(name: 'route_id')
  final String routeId;

  TipModel({
    required this.id,
    required this.name,
    required this.description,
    required this.routeId,
  });

  factory TipModel.fromJson(Map<String, dynamic> json) =>
      _$TipModelFromJson(json);
  Map<String, dynamic> toJson() => _$TipModelToJson(this);
}
