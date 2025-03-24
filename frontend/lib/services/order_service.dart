// lib/services/order_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';

class OrderService {
  Future<Map<String, dynamic>> placeOrder(
    Map<String, dynamic> orderData,
    String token,
  ) async {
    try {
      final url = '${ApiConfig.baseUrl}/orders';

      print('Sending order data: ${json.encode(orderData)}');
      print('To URL: $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'Connection': 'keep-alive',
              'Accept': '*/*',
            },
            body: json.encode(orderData),
          )
          .timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Failed to place order: ${response.statusCode}',
          'data': response.body.isNotEmpty ? json.decode(response.body) : null,
        };
      }
    } catch (e) {
      print('Error placing order: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
