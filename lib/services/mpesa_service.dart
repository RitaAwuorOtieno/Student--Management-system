import 'dart:convert';
import 'package:http/http.dart' as http;

class MpesaService {
  // Base URL configuration for different environments
  // Use demo-server.js for testing (no real M-Pesa credentials needed)
  // Use index.js for real M-Pesa sandbox payments

  // For testing/demo: Use demo-server.js
  // Run with: node demo-server.js (in mpesa-backend folder)
  static const String baseUrl = 'http://localhost:3000';

  // For real M-Pesa sandbox payments, change baseUrl to your ngrok tunnel URL
  // Then run: node start-with-tunnel.js (in mpesa-backend folder)
  // Example: static const String baseUrl = 'https://your-ngrok-url.ngrok-free.app';

  /// Trigger STK Push to user's phone
  static Future<Map<String, dynamic>> initiateSTKPush({
    required String phone,
    required double amount,
    String accountReference = 'Test',
    String transactionDesc = 'Payment',
  }) async {
    try {
      // Format phone number
      String formattedPhone = formatPhoneNumber(phone);

      final response = await http.post(
        Uri.parse('$baseUrl/mpesa/stkpush'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': formattedPhone,
          'amount': amount.toInt(),
          'accountReference': accountReference,
          'transactionDesc': transactionDesc,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'checkoutRequestId': data['data']['CheckoutRequestID'] ?? '',
          'merchantRequestId': data['data']['MerchantRequestID'] ?? '',
          'responseCode': data['data']['ResponseCode'] ?? '',
          'responseDescription': data['data']['ResponseDescription'] ?? '',
          'message': data['message'] ?? 'STK push sent',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to send STK push',
          'error': errorData['error'] ?? '',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error connecting to server',
        'error': e.toString(),
      };
    }
  }

  /// Query the status of an STK push transaction
  static Future<Map<String, dynamic>> queryTransaction({
    required String checkoutRequestId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mpesa/query'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'checkoutRequestId': checkoutRequestId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to query transaction',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error connecting to server',
        'error': e.toString(),
      };
    }
  }

  /// Get transaction status from callback
  static Future<Map<String, dynamic>> getTransactionStatus({
    required String checkoutRequestId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mpesa/transaction/$checkoutRequestId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': 'Failed to get transaction status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error connecting to server',
        'error': e.toString(),
      };
    }
  }

  /// Format phone number to 254XXXXXXXXX format
  static String formatPhoneNumber(String phone) {
    // Remove any spaces, dashes, or special characters
    phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Handle different formats
    if (phone.startsWith('07')) {
      // 07XX XXX XXX -> 2547XX XXX XXX
      return '254${phone.substring(1)}';
    } else if (phone.startsWith('01')) {
      // 01XX XXX XXX -> 2541XX XXX XXX
      return '254${phone.substring(1)}';
    } else if (phone.startsWith('+254')) {
      // +254XX XXX XXX -> 254XX XXX XXX
      return phone.substring(1);
    } else if (phone.startsWith('254')) {
      // Already in correct format
      return phone;
    } else {
      // Return as is, backend will validate
      return phone;
    }
  }

  /// Validate phone number format
  static String? validatePhoneNumber(String phone) {
    phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (phone.isEmpty) {
      return 'Phone number is required';
    }

    // Check for valid Kenyan formats
    final validFormats = [
      RegExp(r'^254[71]\d{8}$'), // 25471XXXXXXXX or 25472XXXXXXXX
      RegExp(r'^07[12]\d{7}$'), // 071XXXXXXXX or 072XXXXXXXX
      RegExp(r'^01[12]\d{7}$'), // 011XXXXXXXX or 012XXXXXXXX
      RegExp(r'^\+254[71]\d{8}$'), // +25471XXXXXXXX or +25472XXXXXXXX
    ];

    bool isValid = validFormats.any((format) => format.hasMatch(phone));

    if (!isValid) {
      return 'Invalid phone number format. Use 07XX or 2547XX format';
    }

    return null;
  }
}
