// Subject Model
class Subject {
  final String id;
  final String name;
  final String code;
  final String description;
  final String category; // e.g., Sciences, Humanities, Languages, Mathematics
  final bool isOptional;
  final int? hoursPerWeek;
  final bool isActive;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    this.description = '',
    this.category = 'General',
    this.isOptional = false,
    this.hoursPerWeek,
    this.isActive = true,
  });

  factory Subject.fromMap(String id, Map<String, dynamic> data) {
    return Subject(
      id: id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'General',
      isOptional: data['isOptional'] ?? false,
      hoursPerWeek: data['hoursPerWeek'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'description': description,
      'category': category,
      'isOptional': isOptional,
      'hoursPerWeek': hoursPerWeek,
      'isActive': isActive,
    };
  }
}

// School Class Model (Grade/Form)
class SchoolClass {
  final String id;
  final String name; // e.g., Grade 1, Form 1, Class 8A
  final String level; // e.g., Primary, Secondary
  final int? streamNumber;
  final String? classTeacherId;
  final int? capacity;
  final String? roomNumber;
  final bool isActive;

  SchoolClass({
    required this.id,
    required this.name,
    this.level = 'Primary',
    this.streamNumber,
    this.classTeacherId,
    this.capacity,
    this.roomNumber,
    this.isActive = true,
  });

  factory SchoolClass.fromMap(String id, Map<String, dynamic> data) {
    return SchoolClass(
      id: id,
      name: data['name'] ?? '',
      level: data['level'] ?? 'Primary',
      streamNumber: data['streamNumber'],
      classTeacherId: data['classTeacherId'],
      capacity: data['capacity'],
      roomNumber: data['roomNumber'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'level': level,
      'streamNumber': streamNumber,
      'classTeacherId': classTeacherId,
      'capacity': capacity,
      'roomNumber': roomNumber,
      'isActive': isActive,
    };
  }

  SchoolClass copyWith({
    String? id,
    String? name,
    String? level,
    int? streamNumber,
    String? classTeacherId,
    int? capacity,
    String? roomNumber,
    bool? isActive,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      streamNumber: streamNumber ?? this.streamNumber,
      classTeacherId: classTeacherId ?? this.classTeacherId,
      capacity: capacity ?? this.capacity,
      roomNumber: roomNumber ?? this.roomNumber,
      isActive: isActive ?? this.isActive,
    );
  }
}

// Subject Assignment to Class
class SubjectClassAssignment {
  final String id;
  final String subjectId;
  final String classId;
  final String teacherId;
  final String? daySchedule; // e.g., Monday, Tuesday
  final String? timeSlot; // e.g., 8:00 AM - 9:00 AM
  final String? roomNumber;
  final String? academicYear;

  SubjectClassAssignment({
    required this.id,
    required this.subjectId,
    required this.classId,
    required this.teacherId,
    this.daySchedule,
    this.timeSlot,
    this.roomNumber,
    this.academicYear,
  });

  factory SubjectClassAssignment.fromMap(String id, Map<String, dynamic> data) {
    return SubjectClassAssignment(
      id: id,
      subjectId: data['subjectId'] ?? '',
      classId: data['classId'] ?? '',
      teacherId: data['teacherId'] ?? '',
      daySchedule: data['daySchedule'],
      timeSlot: data['timeSlot'],
      roomNumber: data['roomNumber'],
      academicYear: data['academicYear'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'classId': classId,
      'teacherId': teacherId,
      'daySchedule': daySchedule,
      'timeSlot': timeSlot,
      'roomNumber': roomNumber,
      'academicYear': academicYear,
    };
  }
}

// Student Class Assignment
class StudentClassAssignment {
  final String id;
  final String studentId;
  final String classId;
  final String? academicYear;
  final String? status; // Active, Promoted, Completed
  final DateTime? assignedDate;

  StudentClassAssignment({
    required this.id,
    required this.studentId,
    required this.classId,
    this.academicYear,
    this.status = 'Active',
    this.assignedDate,
  });

  factory StudentClassAssignment.fromMap(String id, Map<String, dynamic> data) {
    return StudentClassAssignment(
      id: id,
      studentId: data['studentId'] ?? '',
      classId: data['classId'] ?? '',
      academicYear: data['academicYear'],
      status: data['status'] ?? 'Active',
      assignedDate: data['assignedDate'] != null
          ? DateTime.tryParse(data['assignedDate'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'classId': classId,
      'academicYear': academicYear,
      'status': status,
      'assignedDate': assignedDate?.toIso8601String(),
    };
  }
}

// Timetable Slot
class TimetableSlot {
  final String id;
  final String classId;
  final String dayOfWeek; // Monday, Tuesday, etc.
  final int periodNumber;
  final String? subjectId;
  final String? teacherId;
  final String? timeStart;
  final String? timeEnd;
  final String? roomNumber;

  TimetableSlot({
    required this.id,
    required this.classId,
    required this.dayOfWeek,
    required this.periodNumber,
    this.subjectId,
    this.teacherId,
    this.timeStart,
    this.timeEnd,
    this.roomNumber,
  });

  factory TimetableSlot.fromMap(String id, Map<String, dynamic> data) {
    return TimetableSlot(
      id: id,
      classId: data['classId'] ?? '',
      dayOfWeek: data['dayOfWeek'] ?? '',
      periodNumber: data['periodNumber'] ?? 0,
      subjectId: data['subjectId'],
      teacherId: data['teacherId'],
      timeStart: data['timeStart'],
      timeEnd: data['timeEnd'],
      roomNumber: data['roomNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'dayOfWeek': dayOfWeek,
      'periodNumber': periodNumber,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'roomNumber': roomNumber,
    };
  }
}
