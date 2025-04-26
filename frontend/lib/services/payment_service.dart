// lib/services/payment_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';
import '../utils/shared_prefs.dart';

class PaymentService {
  // Tạo thanh toán MoMo
  Future<Map<String, dynamic>> createMomoPayment(
    String orderId,
    String returnUrl,
  ) async {
    try {
      final token = await SharedPrefs.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Bạn cần đăng nhập để thực hiện thanh toán',
        };
      }

      final url = '${ApiConfig.baseUrl}/payments/create-momo/$orderId';
      debugPrint('Creating MoMo payment for order: $orderId');
      debugPrint('API URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'returnUrl': returnUrl}),
      );

      debugPrint('MoMo payment response status: ${response.statusCode}');
      debugPrint('MoMo payment response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Không thể tạo thanh toán MoMo',
        };
      }
    } catch (e) {
      debugPrint('Error creating MoMo payment: $e');
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  // Kiểm tra trạng thái thanh toán
  Future<Map<String, dynamic>> checkPaymentStatus(String paymentId) async {
    try {
      final token = await SharedPrefs.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Bạn cần đăng nhập để kiểm tra thanh toán',
        };
      }

      final url = '${ApiConfig.baseUrl}/payments/status/$paymentId';
      debugPrint('Checking payment status for: $paymentId');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Payment status response: ${response.statusCode}');
      debugPrint('Payment status body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Không thể kiểm tra thanh toán',
        };
      }
    } catch (e) {
      debugPrint('Error checking payment status: $e');
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  // Cập nhật trạng thái thanh toán (dùng cho trường hợp không sử dụng webhook)
  Future<Map<String, dynamic>> processPayment(
    String orderId,
    String resultCode,
  ) async {
    try {
      final token = await SharedPrefs.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Bạn cần đăng nhập để xử lý thanh toán',
        };
      }

      final url = '${ApiConfig.baseUrl}/payments/process-payment';
      debugPrint('Processing payment for order: $orderId');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'orderId': orderId, 'resultCode': resultCode}),
      );

      debugPrint('Process payment response: ${response.statusCode}');
      debugPrint('Process payment body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Không thể xử lý thanh toán',
        };
      }
    } catch (e) {
      debugPrint('Error processing payment: $e');
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  // Mở URL thanh toán MoMo
  Future<bool> openMomoPaymentUrl(String paymentUrl) async {
    try {
      final Uri url = Uri.parse(paymentUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return true;
      } else {
        debugPrint('Could not launch $paymentUrl');
        return false;
      }
    } catch (e) {
      debugPrint('Error launching payment URL: $e');
      return false;
    }
  }
}
