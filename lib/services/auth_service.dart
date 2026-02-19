import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'role_validator.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get usersCollection => _firestore.collection('users');

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Login with email and password
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Register new user with role
  Future<UserCredential> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
  }) async {
    // Validate role - prevent admin role during registration
    final validatedRole = RoleValidator.validateRegistrationRole(role);

    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore with role and isActive
      final userDoc = usersCollection.doc(userCredential.user!.uid);
      await userDoc.set({
        'email': email,
        'fullName': fullName,
        'role': validatedRole.toString().split('.').last,
        'phone': phone ?? '',
        'isActive': true,
        'emailVerified': false,
        'createdAt': DateTime.now().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
      });

      // Skip email verification for now - can be enabled later
      // The user will be logged in without email verification
      // _sendVerificationEmailAsync(userCredential.user!, fullName);

      return userCredential;
    } catch (e) {
      // Log the error for debugging
      print('Registration error: $e');
      rethrow; // Re-throw to let the UI handle the error
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Update user profile
  Future<void> updateProfile({
    required String uid,
    String? fullName,
    String? phone,
    String? profilePhoto,
  }) async {
    final userDoc = usersCollection.doc(uid);
    final updates = <String, dynamic>{};

    if (fullName != null) updates['fullName'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (profilePhoto != null) updates['profilePhoto'] = profilePhoto;

    if (updates.isNotEmpty) {
      await userDoc.update(updates);
    }
  }

  // Update last login time
  Future<void> updateLastLogin(String uid) async {
    await usersCollection.doc(uid).update({
      'lastLogin': DateTime.now().toIso8601String(),
    });
  }

  // Get user data from Firestore
  Future<AppUser?> getUserData(String uid) async {
    try {
      final doc = await usersCollection.doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Stream user data
  Stream<AppUser?> userStream(String uid) {
    return usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Get all users (admin only)
  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await usersCollection.get();
    return snapshot.docs.map((doc) {
      return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // Get users by role
  Future<List<AppUser>> getUsersByRole(UserRole role) async {
    final snapshot = await usersCollection
        .where('role', isEqualTo: role.toString().split('.').last)
        .get();
    return snapshot.docs.map((doc) {
      return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // Update user role (admin only)
  Future<void> updateUserRole(String uid, UserRole role) async {
    await usersCollection.doc(uid).update({
      'role': role.toString().split('.').last,
    });
  }

  // Deactivate user (admin only)
  Future<void> deactivateUser(String uid) async {
    await usersCollection.doc(uid).update({
      'isActive': false,
    });
  }

  // Activate user (admin only)
  Future<void> activateUser(String uid) async {
    await usersCollection.doc(uid).update({
      'isActive': true,
    });
  }

  // Delete user (admin only)
  Future<void> deleteUser(String uid) async {
    // Delete from Firestore
    await usersCollection.doc(uid).delete();
    // Delete from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.uid == uid) {
      await user.delete();
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String uid) async {
    final user = await getUserData(uid);
    return user?.role == UserRole.admin;
  }

  // Check if user has specific permission
  Future<bool> hasPermission(String uid, String permission) async {
    final user = await getUserData(uid);
    if (user == null) return false;
    return RolePermissions.hasPermission(user.role, permission);
  }
}
