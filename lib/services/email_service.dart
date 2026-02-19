import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Backend URL - use 127.0.0.1 instead of localhost for web compatibility
  // For production, replace with your actual backend URL
  static const String _backendUrl = 'http://127.0.0.1:3000';

  /// Send verification email to the registered user
  Future<void> sendVerificationEmail(User user) async {
    try {
      final fullName = user.displayName ?? 'User';
      
      // Call our backend to send the email
      await _sendVerificationEmailViaBackend(
        user.email ?? '',
        fullName,
      );
    } catch (e) {
      // Log but don't fail - user can still use app
      print('Email service warning: $e');
    }
  }

  /// Send verification email via backend service
  Future<void> _sendVerificationEmailViaBackend(
    String email,
    String fullName,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/email/send-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'fullName': fullName,
          'verificationLink': 'https://firebase.google.com/docs/auth/custom-email-handler',
        }),
      ).timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        print('Email API error: ${responseData['message'] ?? response.body}');
        return;
      }

      print('Verification email queued for: $email');
    } catch (e) {
      print('Failed to send verification email via backend: $e');
      // Don't throw - registration is already successful
    }
  }

  /// Check if user's email is verified
  bool isEmailVerified(User user) {
    return user.emailVerified;
  }

  /// Request refresh and get updated verification status
  Future<bool> checkEmailVerification(User user) async {
    try {
      await user.reload();
      return user.emailVerified;
    } catch (e) {
      throw Exception('Failed to check email verification: $e');
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail(User user) async {
    try {
      final fullName = user.displayName ?? 'User';
      await _sendVerificationEmailViaBackend(user.email ?? '', fullName);
    } catch (e) {
      throw Exception('Failed to resend verification email: $e');
    }
  }
}
