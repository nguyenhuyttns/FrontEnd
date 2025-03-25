// lib/services/order_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/models/order.dart';

class OrderService {
  Future<Map<String, dynamic>> placeOrder(
    Map<String, dynamic> orderData,
    String token,
  ) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.ordersEndpoint}';

      debugPrint('Sending order data: ${json.encode(orderData)}');
      debugPrint('To URL: $url');

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

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

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
      debugPrint('Error placing order: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getUserOrders(
    String userId,
    String token,
  ) async {
    try {
      final url =
          '${ApiConfig.baseUrl}${ApiConfig.ordersEndpoint}/get/userorders/$userId';

      debugPrint('Fetching user orders from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Get user orders response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = json.decode(response.body);
        final List<Order> orders =
            ordersJson.map((json) => Order.fromJson(json)).toList();
        return {'success': true, 'data': orders};
      } else {
        debugPrint('Error response: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to fetch orders: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Error fetching user orders: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
