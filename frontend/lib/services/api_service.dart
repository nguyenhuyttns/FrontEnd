// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import '../utils/shared_prefs.dart';

class ApiService {
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      debugPrint('Attempting login for: $email');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract userId from JWT token
        String userId = '';
        if (data['token'] != null) {
          // Extract userId from JWT payload
          userId = _extractUserIdFromToken(data['token']);
          debugPrint('Extracted user ID from token: $userId');
        }

        return {
          'success': true,
          'data': {...data, 'userId': userId},
        };
      } else {
        return {'success': false, 'message': _getErrorMessage(response)};
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } catch (e) {
      debugPrint('Login error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Helper method to extract userId from JWT token
  String _extractUserIdFromToken(String token) {
    try {
      // Split the token into parts
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('Invalid token format');
        return '';
      }

      // Decode the payload (middle part)
      String payload = parts[1];

      // Add padding if needed
      while (payload.length % 4 != 0) {
        payload += '=';
      }

      // Replace characters that are different in URL-safe base64
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');

      // Decode base64
      final decoded = utf8.decode(base64Url.decode(payload));
      final payloadMap = json.decode(decoded);

      // Extract userId from payload
      if (payloadMap.containsKey('userId')) {
        return payloadMap['userId'];
      }

      return '';
    } catch (e) {
      debugPrint('Error extracting userId from token: $e');
      return '';
    }
  }

  // Register with all user information
  Future<Map<String, dynamic>> register(User user, String password) async {
    try {
      final registerData = user.toRegisterJson(password);

      // Print registration data for debugging
      debugPrint('Attempting registration with data:');
      debugPrint(jsonEncode(registerData));

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registerData),
      );

      debugPrint('Register response status: ${response.statusCode}');
      debugPrint('Register response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': _getErrorMessage(response)};
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } catch (e) {
      debugPrint('Registration error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>> getUserById(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Get user response status: ${response.statusCode}');
      debugPrint('Get user response body: ${response.body}');

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return {'success': true, 'data': userData};
      } else {
        return {'success': false, 'message': _getErrorMessage(response)};
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } catch (e) {
      debugPrint('Get user error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get products (with authorization if needed)
  Future<Map<String, dynamic>> getProducts() async {
    try {
      final token = await SharedPrefs.getToken();
      final headers = {'Content-Type': 'application/json'};

      // Add token if available
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.productsEndpoint}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': _getErrorMessage(response)};
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Helper method to extract error message
  String _getErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? 'Error: ${response.statusCode}';
    } catch (e) {
      return 'Error: ${response.statusCode}';
    }
  }
}
