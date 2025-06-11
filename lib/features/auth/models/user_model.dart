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

