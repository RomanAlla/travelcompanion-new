import 'package:json_annotation/json_annotation.dart';
part 'tip_model.g.dart';

@JsonSerializable()
class TipModel {
  final String? id;
  final String description;
  @JsonKey(name: 'route_id')
  final String? routeId;

  TipModel({this.id, required this.description, this.routeId});

  factory TipModel.fromJson(Map<String, dynamic> json) =>
      _$TipModelFromJson(json);
  Map<String, dynamic> toJson() => _$TipModelToJson(this);
}
