class User {
  const User({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    this.email,
    this.avatarUrl,
    this.reputationScore = 0,
  });

  final int id;
  final String name;
  final String phone;
  final String city;
  final String? email;
  final String? avatarUrl;
  final int reputationScore;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String,
        phone: json['phone'] as String,
        city: json['city'] as String,
        email: json['email'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        reputationScore: json['reputation_score'] as int? ?? 0,
      );
}
