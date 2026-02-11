class Fees {
  final String id;
  final String studentId;
  final double amount;
  final String status;
  final String dueDate;
  final String paymentDate;
  final String paymentMethod;
  final String academicYear;
  final String semester;

  Fees({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.status,
    required this.dueDate,
    required this.paymentDate,
    required this.paymentMethod,
    required this.academicYear,
    required this.semester,
  });

  factory Fees.fromMap(String id, Map<String, dynamic> data) {
    return Fees(
      id: id,
      studentId: data['studentId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'Pending',
      dueDate: data['dueDate'] ?? '',
      paymentDate: data['paymentDate'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      academicYear: data['academicYear'] ?? '',
      semester: data['semester'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'amount': amount,
      'status': status,
      'dueDate': dueDate,
      'paymentDate': paymentDate,
      'paymentMethod': paymentMethod,
      'academicYear': academicYear,
      'semester': semester,
    };
  }
}

class Discount {
  final String id;
  final String name;
  final double percentage;
  final String description;
  final String validFrom;
  final String validUntil;
  final bool isEarlyPayment;

  Discount({
    required this.id,
    required this.name,
    required this.percentage,
    required this.description,
    required this.validFrom,
    required this.validUntil,
    required this.isEarlyPayment,
  });

  factory Discount.fromMap(String id, Map<String, dynamic> data) {
    return Discount(
      id: id,
      name: data['name'] ?? '',
      percentage: (data['percentage'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      validFrom: data['validFrom'] ?? '',
      validUntil: data['validUntil'] ?? '',
      isEarlyPayment: data['isEarlyPayment'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'percentage': percentage,
      'description': description,
      'validFrom': validFrom,
      'validUntil': validUntil,
      'isEarlyPayment': isEarlyPayment,
    };
  }
}

class FeeStructure {
  final String id;
  final String className;
  final String term;
  final String academicYear;
  final double tuitionFee;
  final double activityFee;
  final double examFee;
  final double transportFee;
  final double otherFee;
  final double totalFee;

  FeeStructure({
    required this.id,
    required this.className,
    required this.term,
    required this.academicYear,
    required this.tuitionFee,
    required this.activityFee,
    required this.examFee,
    required this.transportFee,
    required this.otherFee,
    required this.totalFee,
  });

  factory FeeStructure.fromMap(String id, Map<String, dynamic> data) {
    return FeeStructure(
      id: id,
      className: data['className'] ?? '',
      term: data['term'] ?? '',
      academicYear: data['academicYear'] ?? '',
      tuitionFee: (data['tuitionFee'] ?? 0).toDouble(),
      activityFee: (data['activityFee'] ?? 0).toDouble(),
      examFee: (data['examFee'] ?? 0).toDouble(),
      transportFee: (data['transportFee'] ?? 0).toDouble(),
      otherFee: (data['otherFee'] ?? 0).toDouble(),
      totalFee: (data['totalFee'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'className': className,
      'term': term,
      'academicYear': academicYear,
      'tuitionFee': tuitionFee,
      'activityFee': activityFee,
      'examFee': examFee,
      'transportFee': transportFee,
      'otherFee': otherFee,
      'totalFee': totalFee,
    };
  }
}

class Payment {
  final String id;
  final String studentId;
  final String studentName;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String receiptNumber;
  final String academicYear;
  final String term;

  Payment({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.receiptNumber,
    required this.academicYear,
    required this.term,
  });

  factory Payment.fromMap(String id, Map<String, dynamic> data) {
    return Payment(
      id: id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      paymentDate: data['paymentDate'] != null
          ? DateTime.parse(data['paymentDate'])
          : DateTime.now(),
      paymentMethod: data['paymentMethod'] ?? '',
      receiptNumber: data['receiptNumber'] ?? '',
      academicYear: data['academicYear'] ?? '',
      term: data['term'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'receiptNumber': receiptNumber,
      'academicYear': academicYear,
      'term': term,
    };
  }
}
