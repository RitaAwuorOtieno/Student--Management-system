import 'dart:convert';
import 'package:http/http.dart' as http;

class MpesaService {
  // Use 10.0.2.2 for Android emulator to access localhost
  // Use localhost for iOS Simulator
  // Use your machine's IP address (e.g., 192.168.x.x) for physical devices
  static const String baseUrl = 'http://10.0.2.2:3000';

  static Future<Map<String, dynamic>> initiateSTKPush({
    required String phone,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/mpesa/stkpush');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'amount': amount,
          'accountReference': accountReference,
          'transactionDesc': transactionDesc,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'STK Push initiated successfully',
          'checkoutRequestId': data['data']?['CheckoutRequestID'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to initiate payment',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e. Ensure server is running.',
      };
    }
  }
}