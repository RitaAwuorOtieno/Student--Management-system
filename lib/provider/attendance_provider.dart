import 'package:flutter/foundation.dart';
import '../models/attendance_models.dart';
import '../models/student.dart';
import '../models/academic_models.dart';

class AttendanceProvider with ChangeNotifier {
  List<AttendanceRecord> _attendanceRecords = [];
  AttendanceFilter _filter = AttendanceFilter();
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  AttendanceFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set records
  void setAttendanceRecords(List<AttendanceRecord> records) {
    _attendanceRecords = records;
    notifyListeners();
  }

  // CRUD Operations
  void addAttendanceRecord(AttendanceRecord record) {
    // Check if record already exists for this student/date
    final existingIndex = _attendanceRecords.indexWhere(
      (r) =>
          r.studentId == record.studentId &&
          r.classId == record.classId &&
          r.date.year == record.date.year &&
          r.date.month == record.date.month &&
          r.date.day == record.date.day,
    );

    if (existingIndex != -1) {
      // Update existing record
      _attendanceRecords[existingIndex] = record;
    } else {
      // Add new record
      _attendanceRecords.add(record);
    }
    notifyListeners();
  }

  // Bulk add attendance for a class
  void markBulkAttendance(List<AttendanceRecord> records) {
    for (final record in records) {
      final existingIndex = _attendanceRecords.indexWhere(
        (r) =>
            r.studentId == record.studentId &&
            r.classId == record.classId &&
            r.date.year == record.date.year &&
            r.date.month == record.date.month &&
            r.date.day == record.date.day,
      );

      if (existingIndex != -1) {
        _attendanceRecords[existingIndex] = record;
      } else {
        _attendanceRecords.add(record);
      }
    }
    notifyListeners();
  }

  void updateAttendanceRecord(AttendanceRecord updated) {
    final index = _attendanceRecords.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      _attendanceRecords[index] = updated;
      notifyListeners();
    }
  }

  void deleteAttendanceRecord(String recordId) {
    _attendanceRecords.removeWhere((r) => r.id == recordId);
    notifyListeners();
  }

  // Filtering
  List<AttendanceRecord> getFilteredRecords() {
    List<AttendanceRecord> result = List.from(_attendanceRecords);

    if (_filter.classId != null) {
      result = result.where((r) => r.classId == _filter.classId).toList();
    }

    if (_filter.studentId != null) {
      result = result.where((r) => r.studentId == _filter.studentId).toList();
    }

    if (_filter.startDate != null) {
      result = result.where((r) => r.date.isAfter(_filter.startDate!)).toList();
    }

    if (_filter.endDate != null) {
      result = result.where((r) => r.date.isBefore(_filter.endDate!)).toList();
    }

    if (_filter.statuses != null && _filter.statuses!.isNotEmpty) {
      result =
          result.where((r) => _filter.statuses!.contains(r.status)).toList();
    }

    return result;
  }

  void setFilter(AttendanceFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void clearFilter() {
    _filter.clear();
    notifyListeners();
  }

  // Query methods
  List<AttendanceRecord> getRecordsForClass(String classId, DateTime date) {
    return _attendanceRecords
        .where((r) =>
            r.classId == classId &&
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day)
        .toList();
  }

  List<AttendanceRecord> getRecordsForStudent(String studentId,
      {DateTime? startDate, DateTime? endDate}) {
    List<AttendanceRecord> result =
        _attendanceRecords.where((r) => r.studentId == studentId).toList();

    if (startDate != null) {
      result = result.where((r) => r.date.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      result = result.where((r) => r.date.isBefore(endDate)).toList();
    }

    return result..sort((a, b) => b.date.compareTo(a.date));
  }

  List<AttendanceRecord> getRecordsForClassDateRange(
      String classId, DateTime startDate, DateTime endDate) {
    return _attendanceRecords
        .where((r) =>
            r.classId == classId &&
            r.date.isAfter(startDate) &&
            r.date.isBefore(endDate))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Summary methods
  DailyAttendanceSummary getDailySummary(
      String classId, DateTime date, int totalStudents) {
    final records = getRecordsForClass(classId, date);

    int present = 0;
    int absent = 0;
    int late = 0;
    int excused = 0;

    for (final record in records) {
      switch (record.status) {
        case AttendanceStatus.present:
          present++;
          break;
        case AttendanceStatus.absent:
          absent++;
          break;
        case AttendanceStatus.late:
          late++;
          break;
        case AttendanceStatus.excused:
          excused++;
          break;
      }
    }

    return DailyAttendanceSummary(
      classId: classId,
      date: date,
      totalStudents: totalStudents,
      present: present,
      absent: absent,
      late: late,
      excused: excused,
    );
  }

  StudentAttendanceSummary getStudentSummary(String studentId,
      String studentName, DateTime startDate, DateTime endDate) {
    final records =
        getRecordsForStudent(studentId, startDate: startDate, endDate: endDate);

    int present = 0;
    int absent = 0;
    int late = 0;
    int excused = 0;

    for (final record in records) {
      switch (record.status) {
        case AttendanceStatus.present:
          present++;
          break;
        case AttendanceStatus.absent:
          absent++;
          break;
        case AttendanceStatus.late:
          late++;
          break;
        case AttendanceStatus.excused:
          excused++;
          break;
      }
    }

    final totalDays = present + absent + late + excused;

    return StudentAttendanceSummary(
      studentId: studentId,
      studentName: studentName,
      totalDays: totalDays,
      present: present,
      absent: absent,
      late: late,
      excused: excused,
    );
  }

  // Check if attendance is already marked for a class on a date
  bool isAttendanceMarked(String classId, DateTime date) {
    return _attendanceRecords.any((r) =>
        r.classId == classId &&
        r.date.year == date.year &&
        r.date.month == date.month &&
        r.date.day == date.day);
  }

  // Get unique dates for a class
  List<DateTime> getAttendanceDates(String classId) {
    final dates = <DateTime>{};
    for (final record in _attendanceRecords) {
      if (record.classId == classId) {
        dates.add(
            DateTime(record.date.year, record.date.month, record.date.day));
      }
    }
    return dates.toList()..sort((a, b) => b.compareTo(a));
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
