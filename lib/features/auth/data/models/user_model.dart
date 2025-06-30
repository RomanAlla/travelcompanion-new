class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? country;
  final DateTime createdAt;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.createdAt,
    this.name,
    this.country,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'name': name,
      'country': country,
      'created_at': createdAt.toIso8601String(),
      'avatar_url': avatarUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      country: json['country'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
