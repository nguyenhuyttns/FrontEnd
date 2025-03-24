// lib/services/user_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import '../utils/shared_prefs.dart';

class UserService {
  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await SharedPrefs.getToken();
      final userId = await SharedPrefs.getUserId();

      if (token == null || userId == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      // Use the usersEndpoint from ApiConfig instead of hardcoding '/api/v1/users'
      final url = '${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/$userId';
      debugPrint('Requesting user profile from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Get user profile response status: ${response.statusCode}');
      debugPrint('Get user profile response body: ${response.body}');

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
      debugPrint('Get user profile error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    User user, {
    String? password,
  }) async {
    try {
      final token = await SharedPrefs.getToken();
      final userId = await SharedPrefs.getUserId();

      if (token == null || userId == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final updateData = user.toUpdateJson(password: password);

      // Use the usersEndpoint from ApiConfig instead of hardcoding '/api/v1/users'
      final url = '${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/$userId';
      debugPrint('Updating user profile at: $url');
      debugPrint('With data: ${jsonEncode(updateData)}');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );

      debugPrint('Update profile response status: ${response.statusCode}');
      debugPrint('Update profile response body: ${response.body}');

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
      debugPrint('Update profile error: $e');
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
