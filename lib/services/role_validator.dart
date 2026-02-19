import '../models/user_model.dart';

/// Validates and sanitizes user roles to prevent privilege escalation
class RoleValidator {
  // List of valid registerable roles
  static const List<String> validRoles = ['student', 'parent', 'teacher', 'accountant'];

  /// Validate if a role string is valid
  static bool isValidRole(String role) {
    return validRoles.contains(role.toLowerCase());
  }

  /// Validate if a role is allowed for registration
  static bool isRegisterableRole(UserRole role) {
    return role == UserRole.student ||
        role == UserRole.parent ||
        role == UserRole.teacher ||
        role == UserRole.accountant;
  }

  /// Ensure admin role cannot be assigned during registration
  static UserRole validateRegistrationRole(UserRole role) {
    if (role == UserRole.admin) {
      // Force to student role if someone tries to register as admin
      return UserRole.student;
    }
    return role;
  }

  /// Verify that a user cannot escalate their own privileges
  static bool canChangeRole(UserRole currentRole, UserRole newRole) {
    // Only admins can change roles
    // Regular users cannot change their own role
    return false;
  }

  /// Check if user is attempting privilege escalation
  static bool isPrivilegeEscalation(String userRole, String attemptedRole) {
    const adminPrivileges = ['admin'];
    
    if (adminPrivileges.contains(attemptedRole) &&
        !adminPrivileges.contains(userRole)) {
      return true;
    }
    return false;
  }

  /// Get the role from Firestore data safely
  static UserRole getSafeRole(Map<String, dynamic> data) {
    final roleString = data['role']?.toString() ?? 'student';
    
    // Validate the role from Firestore
    if (!isValidRole(roleString) && roleString != 'admin') {
      return UserRole.student;
    }
    
    return _stringToRole(roleString);
  }

  static UserRole _stringToRole(String role) {
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
        return UserRole.student;
    }
  }
}
