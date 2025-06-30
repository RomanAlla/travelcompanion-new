class RoutePointModel {
  final String id;
  final String routeId;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  RoutePointModel({
    required this.id,
    required this.routeId,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'route_id': routeId,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RoutePointModel.fromJson(Map<String, dynamic> json) {
    return RoutePointModel(
      id: json['id'] as String,
      routeId: json['route_id'] as String,
      name: json['name'] as String,
      description: json['description'] != null
          ? json['description'] as String
          : null,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
