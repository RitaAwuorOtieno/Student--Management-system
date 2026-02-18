import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/school_stats.dart';

class SchoolStatsProvider with ChangeNotifier {
  SchoolStats _stats = SchoolStats();
  bool _isLoading = false;
  String? _error;

  SchoolStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters for convenient access
  int get totalStudents => _stats.totalStudents;
  int get totalTeachers => _stats.totalTeachers;
  int get totalAccountants => _stats.totalAccountants;
  double get feesCollectionPercentage => _stats.feesCollectionPercentage;
  int get totalFeesCollected => _stats.totalFeesCollected;
  int get totalFeesExpected => _stats.totalFeesExpected;

  Future<void> loadStats() async {
    setLoading(true);
    clearError();

    try {
      // Fetch student count from students collection
      final studentsSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .get();
      final studentCount = studentsSnapshot.docs.length;

      // Fetch teacher count from users collection where role = 'teacher'
      final teachersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'teacher')
          .get();
      final teacherCount = teachersSnapshot.docs.length;

      // Fetch accountant count from users collection where role = 'accountant'
      final accountantsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'accountant')
          .get();
      final accountantCount = accountantsSnapshot.docs.length;

      // Fetch fees data
      final feesSnapshot = await FirebaseFirestore.instance
          .collection('fees')
          .get();
      
      num totalExpected = 0;
      num totalCollected = 0;

      for (var doc in feesSnapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0).toInt();
        final status = data['status'] ?? 'pending';
        
        totalExpected = totalExpected + amount;
        if (status == 'paid' || status == 'completed') {
          totalCollected = totalCollected + amount;
        }
      }

      // Calculate percentage
      double collectionPercentage = 0.0;
      if (totalExpected > 0) {
        collectionPercentage = (totalCollected / totalExpected) * 100;
      }

      _stats = SchoolStats(
        totalStudents: studentCount,
        totalTeachers: teacherCount,
        totalAccountants: accountantCount,
        feesCollectionPercentage: collectionPercentage,
       totalFeesCollected: totalCollected.toInt(),
        totalFeesExpected: totalExpected.toInt(),
      );
    } catch (e) {
      setError('Failed to load school stats: $e');
      // If there's an error, we'll just show 0 values
      _stats = SchoolStats();
    } finally {
      setLoading(false);
    }
  }

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
