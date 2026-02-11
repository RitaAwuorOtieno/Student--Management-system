// Attendance status enum
enum AttendanceStatus {
  present,
  absent,
  late,
  excused,
}

// Attendance Record Model
class AttendanceRecord {
  final String id;
  final String studentId;
  final String classId;
  final DateTime date;
  final AttendanceStatus status;
  final String? remarks;
  final String markedBy;
  final DateTime? markedAt;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.date,
    required this.status,
    this.remarks,
    required this.markedBy,
    this.markedAt,
  });

  factory AttendanceRecord.fromMap(String id, Map<String, dynamic> data) {
    return AttendanceRecord(
      id: id,
      studentId: data['studentId'] ?? '',
      classId: data['classId'] ?? '',
      date:
          data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      status: _parseStatus(data['status']),
      remarks: data['remarks'],
      markedBy: data['markedBy'] ?? '',
      markedAt:
          data['markedAt'] != null ? DateTime.parse(data['markedAt']) : null,
    );
  }

  static AttendanceStatus _parseStatus(dynamic status) {
    if (status is String) {
      switch (status.toLowerCase()) {
        case 'present':
          return AttendanceStatus.present;
        case 'absent':
          return AttendanceStatus.absent;
        case 'late':
          return AttendanceStatus.late;
        case 'excused':
          return AttendanceStatus.excused;
        default:
          return AttendanceStatus.present;
      }
    }
    return AttendanceStatus.present;
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'classId': classId,
      'date': date.toIso8601String().split('T')[0],
      'status': status.toString().split('.').last,
      'remarks': remarks,
      'markedBy': markedBy,
      'markedAt': markedAt?.toIso8601String(),
    };
  }

  String get statusDisplayName {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }
}

// Daily Attendance Summary for a Class
class DailyAttendanceSummary {
  final String classId;
  final DateTime date;
  final int totalStudents;
  final int present;
  final int absent;
  final int late;
  final int excused;
  final double attendancePercentage;

  DailyAttendanceSummary({
    required this.classId,
    required this.date,
    required this.totalStudents,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
  }) : attendancePercentage =
            totalStudents > 0 ? (present / totalStudents) * 100 : 0;

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'date': date.toIso8601String().split('T')[0],
      'totalStudents': totalStudents,
      'present': present,
      'absent': absent,
      'late': late,
      'excused': excused,
      'attendancePercentage': attendancePercentage,
    };
  }
}

// Student Attendance Summary
class StudentAttendanceSummary {
  final String studentId;
  final String studentName;
  final int totalDays;
  final int present;
  final int absent;
  final int late;
  final int excused;
  final double attendancePercentage;

  StudentAttendanceSummary({
    required this.studentId,
    required this.studentName,
    required this.totalDays,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
  }) : attendancePercentage =
            totalDays > 0 ? ((present + excused) / totalDays) * 100 : 0;

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'totalDays': totalDays,
      'present': present,
      'absent': absent,
      'late': late,
      'excused': excused,
      'attendancePercentage': attendancePercentage,
    };
  }
}

// Attendance Filter Options
class AttendanceFilter {
  String? classId;
  DateTime? startDate;
  DateTime? endDate;
  String? studentId;
  List<AttendanceStatus>? statuses;

  AttendanceFilter({
    this.classId,
    this.startDate,
    this.endDate,
    this.studentId,
    this.statuses,
  });

  void clear() {
    classId = null;
    startDate = null;
    endDate = null;
    studentId = null;
    statuses = null;
  }

  bool get hasFilters =>
      classId != null ||
      startDate != null ||
      endDate != null ||
      studentId != null;
}
