class Course {
  final String id;
  final String code;
  final String name;
  final int credits;
  final String description;
  final String semester;
  final int year;

  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    required this.description,
    required this.semester,
    required this.year,
  });

  factory Course.fromMap(String id, Map<String, dynamic> data) {
    return Course(
      id: id,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      credits: data['credits'] ?? 0,
      description: data['description'] ?? '',
      semester: data['semester'] ?? '',
      year: data['year'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'credits': credits,
      'description': description,
      'semester': semester,
      'year': year,
    };
  }
}
