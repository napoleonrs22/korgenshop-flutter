/// Пользователь из GET /auth/me и ответов входа.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.emailVerified,
    this.photo,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: '${json['name'] ?? ''}',
      email: '${json['email'] ?? ''}',
      phone: '${json['phone'] ?? ''}',
      emailVerified: json['email_verified'] == true,
      photo: json['photo'] is String && (json['photo'] as String).isNotEmpty
          ? json['photo'] as String
          : null,
    );
  }

  final int id;
  final String name;
  final String email;
  final String phone;
  final bool emailVerified;
  final String? photo;
}
