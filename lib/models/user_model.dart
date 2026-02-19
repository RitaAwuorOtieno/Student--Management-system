// User roles enum
enum UserRole { admin, teacher, accountant, student, parent }

// Role permissions
class RolePermissions {
  static const Map<UserRole, List<String>> permissions = {
    UserRole.admin: [
      'manage_students',
      'manage_teachers',
      'manage_accountants',
      'manage_fees',
      'view_reports',
      'manage_settings',
      'delete_any_data',
    ],
    UserRole.teacher: [
      'view_students',
      'view_fees',
      'add_grades',
      'view_reports',
    ],
    UserRole.accountant: [
      'view_students',
      'manage_fees',
      'view_reports',
      'process_payments',
    ],
    UserRole.student: [
      'view_own_profile',
      'view_own_grades',
      'view_own_fees',
    ],
    UserRole.parent: [
      'view_child_profile',
      'view_child_grades',
      'view_child_fees',
    ],
  };

  static bool hasPermission(UserRole role, String permission) {
    return permissions[role]?.contains(permission) ?? false;
  }

  static List<String> getPermissions(UserRole role) {
    return permissions[role] ?? [];
  }
}

class AppUser {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? phone;
  final String? profilePhoto;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.profilePhoto,
    this.isActive = true,
    this.createdAt,
    this.lastLogin,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      role: _parseRole(data['role']),
      phone: data['phone'],
      profilePhoto: data['profilePhoto'],
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'])
          : null,
      lastLogin: data['lastLogin'] != null
          ? DateTime.tryParse(data['lastLogin'])
          : null,
    );
  }

  static UserRole _parseRole(dynamic role) {
    if (role is String) {
      switch (role.toLowerCase()) {
        case 'admin':
          return UserRole.admin;
        case 'teacher':
          return UserRole.teacher;
        case 'accountant':
          return UserRole.accountant;
        case 'student':
          return UserRole.student;
        case 'parent':
          return UserRole.parent;
        default:
          // Default to student role to prevent privilege escalation
          return UserRole.student;
      }
    }
    // Default to student role if role is invalid type
    return UserRole.student;
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role.toString().split('.').last,
      'phone': phone,
      'profilePhoto': profilePhoto,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  // Permission checks
  bool get canManageStudents =>
      RolePermissions.hasPermission(role, 'manage_students');
  bool get canManageFees => RolePermissions.hasPermission(role, 'manage_fees');
  bool get canViewReports =>
      RolePermissions.hasPermission(role, 'view_reports');
  bool get canDeleteData =>
      RolePermissions.hasPermission(role, 'delete_any_data');
  bool get canManageUsers => role == UserRole.admin;

  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.accountant:
        return 'Accountant';
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
    }
  }

  String get roleDescription {
    switch (role) {
      case UserRole.admin:
        return 'Full access to all features and settings';
      case UserRole.teacher:
        return 'Can view students and add grades';
      case UserRole.accountant:
        return 'Can manage fees and process payments';
      case UserRole.student:
        return 'Can view own profile, grades, and fees';
      case UserRole.parent:
        return 'Can view child profile, grades, and fees';
    }
  }
}

// Extension methods for UserRole enum
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.accountant:
        return 'Accountant';
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
    }
  }

  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Full access to all features and settings';
      case UserRole.teacher:
        return 'Can view students and add grades';
      case UserRole.accountant:
        return 'Can manage fees and process payments';
      case UserRole.student:
        return 'Can view own profile, grades, and fees';
      case UserRole.parent:
        return 'Can view child profile, grades, and fees';
    }
  }
}
