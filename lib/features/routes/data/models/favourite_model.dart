class FavouriteModel {
  final String id;
  final String userId;
  final String routeId;
  final DateTime createdAt;

  FavouriteModel(
      {required this.id,
      required this.userId,
      required this.routeId,
      required this.createdAt});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'route_id': routeId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FavouriteModel.fromJson(Map<String, dynamic> json) {
    return FavouriteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      routeId: json['route_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
