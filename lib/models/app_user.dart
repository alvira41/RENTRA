
class AppUser {
  final String id;
  final String email;
  final String role;
  final int? profileId;
  final String name;

  const AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    this.profileId,
  });

  bool get isAdmin => role == 'admin';
  bool get isMitra => role == 'mitra';
  bool get isUser => role == 'user';

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      role: map['role'] as String,
      profileId: map['profile_id'] as int?,
      name: map['name'] as String? ?? '',
    );
  }
}
