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
