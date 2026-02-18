class SchoolStats {
  final int totalStudents;
  final int totalTeachers;
  final int totalAccountants;
  final double feesCollectionPercentage;
  final int totalFeesCollected;
  final int totalFeesExpected;

  SchoolStats({
    this.totalStudents = 0,
    this.totalTeachers = 0,
    this.totalAccountants = 0,
    this.feesCollectionPercentage = 0.0,
    this.totalFeesCollected = 0,
    this.totalFeesExpected = 0,
  });

  factory SchoolStats.fromMap(Map<String, dynamic> data) {
    return SchoolStats(
      totalStudents: data['totalStudents'] ?? 0,
      totalTeachers: data['totalTeachers'] ?? 0,
      totalAccountants: data['totalAccountants'] ?? 0,
      feesCollectionPercentage: (data['feesCollectionPercentage'] ?? 0.0).toDouble(),
      totalFeesCollected: data['totalFeesCollected'] ?? 0,
      totalFeesExpected: data['totalFeesExpected'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalStudents': totalStudents,
      'totalTeachers': totalTeachers,
      'totalAccountants': totalAccountants,
      'feesCollectionPercentage': feesCollectionPercentage,
      'totalFeesCollected': totalFeesCollected,
      'totalFeesExpected': totalFeesExpected,
    };
  }
}
