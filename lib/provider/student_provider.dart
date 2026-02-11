import 'package:flutter/foundation.dart';
import '../models/student.dart';

class StudentProvider with ChangeNotifier {
  List<Student> _students = [];
  bool _isLoading = false;
  String? _error;

  // Filter states
  String _searchQuery = '';
  String _filterClass = '';
  String _filterGender = '';
  String _filterStatus = '';

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter getters
  String get searchQuery => _searchQuery;
  String get filterClass => _filterClass;
  String get filterGender => _filterGender;
  String get filterStatus => _filterStatus;

  // Get filtered students
  List<Student> get filteredStudents {
    List<Student> result = _students;

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((student) {
        return student.fullName.toLowerCase().contains(query) ||
            student.admissionNumber.toLowerCase().contains(query) ||
            student.parentName.toLowerCase().contains(query) ||
            student.phone.contains(query);
      }).toList();
    }

    // Apply class filter
    if (_filterClass.isNotEmpty) {
      result = result
          .where((student) => student.classGrade == _filterClass)
          .toList();
    }

    // Apply gender filter
    if (_filterGender.isNotEmpty) {
      result =
          result.where((student) => student.gender == _filterGender).toList();
    }

    // Apply status filter
    if (_filterStatus.isNotEmpty) {
      result =
          result.where((student) => student.status == _filterStatus).toList();
    }

    return result;
  }

  // Get unique classes for filter dropdown
  List<String> get uniqueClasses {
    return _students
        .map((s) => s.classGrade)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  // Get student count by status
  int get activeCount => _students.where((s) => s.status == 'Active').length;
  int get inactiveCount =>
      _students.where((s) => s.status == 'Inactive').length;
  int get totalCount => _students.length;

  // CRUD Operations
  void setStudents(List<Student> students) {
    _students = students;
    notifyListeners();
  }

  void addStudent(Student student) {
    _students.add(student);
    notifyListeners();
  }

  void updateStudent(Student updatedStudent) {
    final index = _students.indexWhere((s) => s.id == updatedStudent.id);
    if (index != -1) {
      _students[index] = updatedStudent;
      notifyListeners();
    }
  }

  void removeStudent(String studentId) {
    _students.removeWhere((s) => s.id == studentId);
    notifyListeners();
  }

  // Filter operations
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterClass(String className) {
    _filterClass = className;
    notifyListeners();
  }

  void setFilterGender(String gender) {
    _filterGender = gender;
    notifyListeners();
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterClass = '';
    _filterGender = '';
    _filterStatus = '';
    notifyListeners();
  }

  // Get single student by ID
  Student? getStudentById(String id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  // Loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Error handling
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
  }
}
