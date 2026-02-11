import 'package:flutter/foundation.dart';
import '../models/academic_models.dart';
import '../models/student.dart';
import '../models/user_model.dart';

class AcademicProvider with ChangeNotifier {
  // Lists
  List<Subject> _subjects = [];
  List<SchoolClass> _classes = [];
  List<SubjectClassAssignment> _subjectAssignments = [];
  List<StudentClassAssignment> _studentAssignments = [];
  List<TimetableSlot> _timetableSlots = [];

  // Loading states
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Subject> get subjects => _subjects;
  List<SchoolClass> get classes => _classes;
  List<SubjectClassAssignment> get subjectAssignments => _subjectAssignments;
  List<StudentClassAssignment> get studentAssignments => _studentAssignments;
  List<TimetableSlot> get timetableSlots => _timetableSlots;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered getters
  List<Subject> get activeSubjects =>
      _subjects.where((s) => s.isActive).toList();
  List<SchoolClass> get activeClasses =>
      _classes.where((c) => c.isActive).toList();

  List<SchoolClass> get classesByLevel => _groupClassesByLevel();

  // Set data methods
  void setSubjects(List<Subject> subjects) {
    _subjects = subjects;
    notifyListeners();
  }

  void setClasses(List<SchoolClass> classes) {
    _classes = classes;
    notifyListeners();
  }

  void setSubjectAssignments(List<SubjectClassAssignment> assignments) {
    _subjectAssignments = assignments;
    notifyListeners();
  }

  void setStudentAssignments(List<StudentClassAssignment> assignments) {
    _studentAssignments = assignments;
    notifyListeners();
  }

  void setTimetableSlots(List<TimetableSlot> slots) {
    _timetableSlots = slots;
    notifyListeners();
  }

  // CRUD Operations - Subjects
  void addSubject(Subject subject) {
    _subjects.add(subject);
    notifyListeners();
  }

  void updateSubject(Subject updated) {
    final index = _subjects.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _subjects[index] = updated;
      notifyListeners();
    }
  }

  void deleteSubject(String subjectId) {
    _subjects.removeWhere((s) => s.id == subjectId);
    // Also remove related assignments
    _subjectAssignments.removeWhere((a) => a.subjectId == subjectId);
    notifyListeners();
  }

  // CRUD Operations - Classes
  void addClass(SchoolClass schoolClass) {
    _classes.add(schoolClass);
    notifyListeners();
  }

  void updateClass(SchoolClass updated) {
    final index = _classes.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _classes[index] = updated;
      notifyListeners();
    }
  }

  void deleteClass(String classId) {
    _classes.removeWhere((c) => c.id == classId);
    // Also remove related assignments
    _subjectAssignments.removeWhere((a) => a.classId == classId);
    _studentAssignments.removeWhere((a) => a.classId == classId);
    _timetableSlots.removeWhere((t) => t.classId == classId);
    notifyListeners();
  }

  // Subject-Class Assignment
  void assignSubjectToClass(SubjectClassAssignment assignment) {
    // Check if assignment already exists
    final existing = _subjectAssignments.indexWhere(
      (a) =>
          a.subjectId == assignment.subjectId &&
          a.classId == assignment.classId &&
          a.teacherId == assignment.teacherId,
    );
    if (existing == -1) {
      _subjectAssignments.add(assignment);
      notifyListeners();
    }
  }

  void removeSubjectAssignment(String assignmentId) {
    _subjectAssignments.removeWhere((a) => a.id == assignmentId);
    notifyListeners();
  }

  // Student-Class Assignment
  void assignStudentToClass(StudentClassAssignment assignment) {
    final existing = _studentAssignments.indexWhere(
      (a) =>
          a.studentId == assignment.studentId &&
          a.classId == assignment.classId,
    );
    if (existing == -1) {
      _studentAssignments.add(assignment);
      notifyListeners();
    } else {
      // Update existing assignment
      _studentAssignments[existing] = assignment;
    }
    notifyListeners();
  }

  void removeStudentFromClass(String studentId, String classId) {
    _studentAssignments.removeWhere(
      (a) => a.studentId == studentId && a.classId == classId,
    );
    notifyListeners();
  }

  void assignClassTeacher(String classId, String teacherId) {
    final index = _classes.indexWhere((c) => c.id == classId);
    if (index != -1) {
      _classes[index] = _classes[index].copyWith(classTeacherId: teacherId);
      notifyListeners();
    }
  }

  // Query methods
  List<SubjectClassAssignment> getAssignmentsForClass(String classId) {
    return _subjectAssignments.where((a) => a.classId == classId).toList();
  }

  List<SubjectClassAssignment> getAssignmentsForTeacher(String teacherId) {
    return _subjectAssignments.where((a) => a.teacherId == teacherId).toList();
  }

  List<StudentClassAssignment> getClassesForStudent(String studentId) {
    return _studentAssignments.where((a) => a.studentId == studentId).toList();
  }

  List<StudentClassAssignment> getStudentsForClass(String classId) {
    return _studentAssignments.where((a) => a.classId == classId).toList();
  }

  List<TimetableSlot> getTimetableForClass(String classId) {
    return _timetableSlots.where((t) => t.classId == classId).toList()
      ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
  }

  // Get teachers (users with Teacher role)
  List<AppUser> getTeachers(List<AppUser> allUsers) {
    return allUsers.where((u) => u.role == UserRole.teacher).toList();
  }

  // Get students (users with Student role)
  List<AppUser> getStudents(List<AppUser> allUsers) {
    return allUsers.where((u) => u.role == UserRole.student).toList();
  }

  // Helper methods
  List<SchoolClass> _groupClassesByLevel() {
    final grouped = <String, List<SchoolClass>>{};
    for (final classItem in _classes) {
      if (!grouped.containsKey(classItem.level)) {
        grouped[classItem.level] = [];
      }
      grouped[classItem.level]!.add(classItem);
    }
    return grouped.values.expand((e) => e).toList();
  }

  Subject? getSubjectById(String id) {
    try {
      return _subjects.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  SchoolClass? getClassById(String id) {
    try {
      return _classes.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Loading and error states
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
