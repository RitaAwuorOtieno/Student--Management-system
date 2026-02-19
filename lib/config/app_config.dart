/// Environment configuration for the app
/// This file contains configuration values from Firebase and environment variables
class AppConfig {
  // Firebase project ID - retrieved from firebase.json
  static const String firebaseProjectId = 'crud-firestore-app-75516';
  
  // Firestore collections
  static const String usersCollection = 'users';
  static const String studentsCollection = 'students';
  static const String feesCollection = 'fees';
  static const String attendanceCollection = 'attendance';
  static const String academicsCollection = 'academics';
  static const String examsCollection = 'exams';

  // Email configuration - using Firebase Authentication for email verification
  // Firebase Auth handles verification emails automatically
  static const bool useFirebaseEmailVerification = true;

  // Security constants
  static const List<String> adminOnlyRoles = ['admin'];
  static const List<String> parentRoles = ['parent'];
  static const List<String> studentRoles = ['student'];
  static const List<String> teacherRoles = ['teacher'];
  static const List<String> accountantRoles = ['accountant'];
}
