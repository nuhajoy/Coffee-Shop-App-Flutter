enum UserRole {
  admin,
  employee;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'employee':
        return UserRole.employee;
      default:
        return UserRole.employee;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.employee:
        return 'Employee';
    }
  }
}

class User {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final UserRole role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.role = UserRole.employee,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isEmployee => role == UserRole.employee;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'employee'),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role.name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
