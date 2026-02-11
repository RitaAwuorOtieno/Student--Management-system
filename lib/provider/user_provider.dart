import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isTeacher => _currentUser?.role == UserRole.teacher;
  bool get isAccountant => _currentUser?.role == UserRole.accountant;
  bool get isStudent => _currentUser?.role == UserRole.student;
  bool get isParent => _currentUser?.role == UserRole.parent;

  // Permission checks
  bool get canManageStudents => _currentUser?.canManageStudents ?? false;
  bool get canManageFees => _currentUser?.canManageFees ?? false;
  bool get canViewReports => _currentUser?.canViewReports ?? false;
  bool get canDeleteData => _currentUser?.canDeleteData ?? false;

  Future<void> loadUser(String uid) async {
    setLoading(true);
    clearError();

    try {
      final user = await AuthService().getUserData(uid);
      _currentUser = user;

      // Update last login
      if (user != null) {
        await AuthService().updateLastLogin(uid);
      }
    } catch (e) {
      setError('Failed to load user: $e');
    } finally {
      setLoading(false);
    }
  }

  Stream<AppUser?> userStream(String uid) {
    return AuthService().userStream(uid);
  }

  void setUser(AppUser? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
    await AuthService().logout();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
  }
}
