class Student {
  final String id;
  final String regNo;
  final String name;
  final String course;
  final int year;
  final String gender;

  Student({
    required this.id,
    required this.regNo,
    required this.name,
    required this.course,
    required this.year,
    required this.gender,
  });

  factory Student.fromMap(String id, Map<String, dynamic> data) {
    return Student(
      id: id,
      regNo: data['regNo'],
      name: data['name'],
      course: data['course'],
      year: data['year'],
      gender: data['gender'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'regNo': regNo,
      'name': name,
      'course': course,
      'year': year,
      'gender': gender,
    };
  }
}
