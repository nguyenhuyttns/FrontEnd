// lib/utils/shared_prefs.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String tokenKey = 'auth_token';
  static const String userEmailKey = 'user_email';

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);

    debugPrint('Token saved to SharedPreferences');
    if (kDebugMode) {
      debugPrint(
        'Token (first 20 chars): ${token.substring(0, min(20, token.length))}...',
      );
    }
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);

    if (token != null && kDebugMode) {
      debugPrint('Retrieved token from SharedPreferences');
      debugPrint(
        'Token (first 20 chars): ${token.substring(0, min(20, token.length))}...',
      );
    } else if (kDebugMode) {
      debugPrint('No token found in SharedPreferences');
    }

    return token;
  }

  // Save user email
  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userEmailKey, email);
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  // Clear all stored data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
