class Student {
  final String id;
  final String admissionNumber;
  final String fullName;
  final DateTime? dateOfBirth;
  final String gender;
  final String classGrade;
  final String status;

  // Parent/Guardian details
  final String parentName;
  final String parentPhone;
  final String parentEmail;
  final String relationship; // e.g., Father, Mother, Guardian

  // Contact information
  final String phone;
  final String email;

  // Address
  final String address;
  final String city;
  final String county;

  // Photo
  final String? photoUrl;

  // Additional fields
  final DateTime? admissionDate;
  final String notes;

  Student({
    required this.id,
    required this.admissionNumber,
    required this.fullName,
    this.dateOfBirth,
    required this.gender,
    required this.classGrade,
    this.status = 'Active',
    required this.parentName,
    required this.parentPhone,
    this.parentEmail = '',
    required this.relationship,
    required this.phone,
    this.email = '',
    required this.address,
    required this.city,
    this.county = '',
    this.photoUrl,
    this.admissionDate,
    this.notes = '',
  });

  factory Student.fromMap(String id, Map<String, dynamic> data) {
    return Student(
      id: id,
      admissionNumber: data['admissionNumber'] ?? '',
      fullName: data['fullName'] ?? '',
      dateOfBirth: data['dateOfBirth'] != null
          ? DateTime.tryParse(data['dateOfBirth'])
          : null,
      gender: data['gender'] ?? 'Male',
      classGrade: data['classGrade'] ?? '',
      status: data['status'] ?? 'Active',
      parentName: data['parentName'] ?? '',
      parentPhone: data['parentPhone'] ?? '',
      parentEmail: data['parentEmail'] ?? '',
      relationship: data['relationship'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      county: data['county'] ?? '',
      photoUrl: data['photoUrl'],
      admissionDate: data['admissionDate'] != null
          ? DateTime.tryParse(data['admissionDate'])
          : null,
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'admissionNumber': admissionNumber,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'classGrade': classGrade,
      'status': status,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'parentEmail': parentEmail,
      'relationship': relationship,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'county': county,
      'photoUrl': photoUrl,
      'admissionDate': admissionDate?.toIso8601String(),
      'notes': notes,
    };
  }

  // Copy with method for updates
  Student copyWith({
    String? id,
    String? admissionNumber,
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? classGrade,
    String? status,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
    String? relationship,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? county,
    String? photoUrl,
    DateTime? admissionDate,
    String? notes,
  }) {
    return Student(
      id: id ?? this.id,
      admissionNumber: admissionNumber ?? this.admissionNumber,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      classGrade: classGrade ?? this.classGrade,
      status: status ?? this.status,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      parentEmail: parentEmail ?? this.parentEmail,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      county: county ?? this.county,
      photoUrl: photoUrl ?? this.photoUrl,
      admissionDate: admissionDate ?? this.admissionDate,
      notes: notes ?? this.notes,
    );
  }

  // Helper methods
  bool get isActive => status == 'Active';
  String get initials =>
      fullName.split(' ').map((e) => e[0]).take(2).join('').toUpperCase();
}
