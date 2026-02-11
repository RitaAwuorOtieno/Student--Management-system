// Exam Types
enum ExamType { midterm, endTerm, CAT, assignment, practical }

// Grade System
enum Grade {
  A,
  A_minus,
  B_plus,
  B,
  B_minus,
  C_plus,
  C,
  C_minus,
  D_plus,
  D,
  D_minus,
  E
}

// Exam Model
class Exam {
  final String id;
  final String name;
  final String classId;
  final String subjectId;
  final ExamType type;
  final DateTime date;
  final int maxMarks;
  final String? description;
  final String academicYear;
  final String term;

  Exam({
    required this.id,
    required this.name,
    required this.classId,
    required this.subjectId,
    required this.type,
    required this.date,
    required this.maxMarks,
    this.description,
    required this.academicYear,
    required this.term,
  });

  factory Exam.fromMap(String id, Map<String, dynamic> data) {
    return Exam(
      id: id,
      name: data['name'] ?? '',
      classId: data['classId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      type: _parseExamType(data['type']),
      date:
          data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      maxMarks: data['maxMarks'] ?? 100,
      description: data['description'],
      academicYear: data['academicYear'] ?? '',
      term: data['term'] ?? '',
    );
  }

  static ExamType _parseExamType(dynamic type) {
    if (type is String) {
      switch (type.toLowerCase()) {
        case 'midterm':
          return ExamType.midterm;
        case 'endterm':
          return ExamType.endTerm;
        case 'cat':
          return ExamType.CAT;
        case 'assignment':
          return ExamType.assignment;
        case 'practical':
          return ExamType.practical;
        default:
          return ExamType.CAT;
      }
    }
    return ExamType.CAT;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'classId': classId,
      'subjectId': subjectId,
      'type': type.toString().split('.').last,
      'date': date.toIso8601String(),
      'maxMarks': maxMarks,
      'description': description,
      'academicYear': academicYear,
      'term': term,
    };
  }

  String get typeDisplayName {
    switch (type) {
      case ExamType.midterm:
        return 'Midterm';
      case ExamType.endTerm:
        return 'End Term';
      case ExamType.CAT:
        return 'CAT';
      case ExamType.assignment:
        return 'Assignment';
      case ExamType.practical:
        return 'Practical';
    }
  }
}

// Result/Marks Model
class Result {
  final String id;
  final String examId;
  final String studentId;
  final double marksObtained;
  final String? remarks;
  final String gradedBy;
  final DateTime? gradedAt;

  Result({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.marksObtained,
    this.remarks,
    required this.gradedBy,
    this.gradedAt,
  });

  factory Result.fromMap(String id, Map<String, dynamic> data) {
    return Result(
      id: id,
      examId: data['examId'] ?? '',
      studentId: data['studentId'] ?? '',
      marksObtained: (data['marksObtained'] ?? 0).toDouble(),
      remarks: data['remarks'],
      gradedBy: data['gradedBy'] ?? '',
      gradedAt:
          data['gradedAt'] != null ? DateTime.parse(data['gradedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'studentId': studentId,
      'marksObtained': marksObtained,
      'remarks': remarks,
      'gradedBy': gradedBy,
      'gradedAt': gradedAt?.toIso8601String(),
    };
  }

  // Calculate grade based on percentage
  Grade getGrade(int maxMarks) {
    final percentage = (marksObtained / maxMarks) * 100;
    if (percentage >= 90) return Grade.A;
    if (percentage >= 85) return Grade.A_minus;
    if (percentage >= 80) return Grade.B_plus;
    if (percentage >= 75) return Grade.B;
    if (percentage >= 70) return Grade.B_minus;
    if (percentage >= 65) return Grade.C_plus;
    if (percentage >= 60) return Grade.C;
    if (percentage >= 55) return Grade.C_minus;
    if (percentage >= 50) return Grade.D_plus;
    if (percentage >= 45) return Grade.D;
    if (percentage >= 40) return Grade.D_minus;
    return Grade.E;
  }

  String getGradeDisplay() {
    switch (getGrade(100)) {
      case Grade.A:
        return 'A';
      case Grade.A_minus:
        return 'A-';
      case Grade.B_plus:
        return 'B+';
      case Grade.B:
        return 'B';
      case Grade.B_minus:
        return 'B-';
      case Grade.C_plus:
        return 'C+';
      case Grade.C:
        return 'C';
      case Grade.C_minus:
        return 'C-';
      case Grade.D_plus:
        return 'D+';
      case Grade.D:
        return 'D';
      case Grade.D_minus:
        return 'D-';
      case Grade.E:
        return 'E';
    }
  }

  String getGradePoints() {
    switch (getGrade(100)) {
      case Grade.A:
        return '12';
      case Grade.A_minus:
        return '11';
      case Grade.B_plus:
        return '10';
      case Grade.B:
        return '9';
      case Grade.B_minus:
        return '8';
      case Grade.C_plus:
        return '7';
      case Grade.C:
        return '6';
      case Grade.C_minus:
        return '5';
      case Grade.D_plus:
        return '4';
      case Grade.D:
        return '3';
      case Grade.D_minus:
        return '2';
      case Grade.E:
        return '1';
    }
  }
}

// Student Report Card
class ReportCard {
  final String studentId;
  final String studentName;
  final String className;
  final String academicYear;
  final String term;
  final double totalMarks;
  final double averageMarks;
  final int totalSubjects;
  final int position;
  final int totalStudents;
  final Grade overallGrade;
  final List<SubjectResult> subjectResults;
  final String? teacherRemarks;
  final String? principalRemarks;

  ReportCard({
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.academicYear,
    required this.term,
    required this.totalMarks,
    required this.averageMarks,
    required this.totalSubjects,
    required this.position,
    required this.totalStudents,
    required this.overallGrade,
    required this.subjectResults,
    this.teacherRemarks,
    this.principalRemarks,
  });
}

class SubjectResult {
  final String subjectName;
  final double marks;
  final Grade grade;
  final String gradePoints;
  final int rank;

  SubjectResult({
    required this.subjectName,
    required this.marks,
    required this.grade,
    required this.gradePoints,
    required this.rank,
  });
}

// Fee Structure Model
class FeeStructure {
  final String id;
  final String name; // e.g., "Tuition Fee", "Development Fee"
  final String classId;
  final double amount;
  final String feeType; // compulsory, optional
  final String academicYear;
  final String term;
  final DateTime dueDate;
  final String? description;

  FeeStructure({
    required this.id,
    required this.name,
    required this.classId,
    required this.amount,
    required this.feeType,
    required this.academicYear,
    required this.term,
    required this.dueDate,
    this.description,
  });

  factory FeeStructure.fromMap(String id, Map<String, dynamic> data) {
    return FeeStructure(
      id: id,
      name: data['name'] ?? '',
      classId: data['classId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      feeType: data['feeType'] ?? 'compulsory',
      academicYear: data['academicYear'] ?? '',
      term: data['term'] ?? '',
      dueDate: data['dueDate'] != null
          ? DateTime.parse(data['dueDate'])
          : DateTime.now(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'classId': classId,
      'amount': amount,
      'feeType': feeType,
      'academicYear': academicYear,
      'term': term,
      'dueDate': dueDate.toIso8601String(),
      'description': description,
    };
  }
}

// Payment Model
class Payment {
  final String id;
  final String studentId;
  final String feeStructureId;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod; // cash, mpesa, bank
  final String transactionId;
  final String receivedBy;
  final String? receiptNumber;
  final String status; // completed, pending, failed

  Payment({
    required this.id,
    required this.studentId,
    required this.feeStructureId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.transactionId,
    required this.receivedBy,
    this.receiptNumber,
    this.status = 'completed',
  });

  factory Payment.fromMap(String id, Map<String, dynamic> data) {
    return Payment(
      id: id,
      studentId: data['studentId'] ?? '',
      feeStructureId: data['feeStructureId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      paymentDate: data['paymentDate'] != null
          ? DateTime.parse(data['paymentDate'])
          : DateTime.now(),
      paymentMethod: data['paymentMethod'] ?? 'cash',
      transactionId: data['transactionId'] ?? '',
      receivedBy: data['receivedBy'] ?? '',
      receiptNumber: data['receiptNumber'],
      status: data['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'feeStructureId': feeStructureId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'receivedBy': receivedBy,
      'receiptNumber': receiptNumber,
      'status': status,
    };
  }
}

// Student Fee Balance
class StudentFeeBalance {
  final String studentId;
  final String studentName;
  final String className;
  final double totalFees;
  final double totalPaid;
  final double balance;
  final List<FeeStructure> feeStructures;
  final List<Payment> payments;

  StudentFeeBalance({
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.totalFees,
    required this.totalPaid,
    required this.balance,
    required this.feeStructures,
    required this.payments,
  });

  double getBalance() => totalFees - totalPaid;
}
