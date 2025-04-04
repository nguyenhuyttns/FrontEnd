// lib/view_models/auth_view_model.dart
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/shared_prefs.dart';
import 'base_view_model.dart';

class AuthViewModel extends BaseViewModel {
  final ApiService _apiService = ApiService();
  String? _userEmail;
  String? _userId; // Add userId field
  bool _isLoggedIn = false;
  String? _token;

  String? get userEmail => _userEmail;
  String? get userId => _userId; // Getter for userId
  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;

  AuthViewModel() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    setBusy();
    _isLoggedIn = await SharedPrefs.isLoggedIn();
    if (_isLoggedIn) {
      _userEmail = await SharedPrefs.getUserEmail();
      _userId = await SharedPrefs.getUserId(); // Get stored userId
      _token = await SharedPrefs.getToken();
      debugPrint('Retrieved stored token: $_token');
      debugPrint('Retrieved stored userId: $_userId');
    }
    setIdle();
  }

  Future<bool> login(String email, String password) async {
    setBusy();

    final result = await _apiService.login(email, password);
    debugPrint('Login result: $result');

    if (result['success']) {
      final data = result['data'];
      final token = data['token'];
      final userEmail = data['user'];
      final userId = data['userId']; // Extract userId from response

      // Print the token and userId to console
      debugPrint('==================== LOGIN INFO ====================');
      debugPrint('Token: $token');
      debugPrint('User ID: $userId');
      debugPrint('=====================================================');

      await SharedPrefs.saveToken(token);
      await SharedPrefs.saveUserEmail(userEmail);
      await SharedPrefs.saveUserId(userId); // Save userId to SharedPrefs

      _userEmail = userEmail;
      _userId = userId; // Store userId in view model
      _token = token;
      _isLoggedIn = true;
      setIdle();
      return true;
    } else {
      setError(result['message'] ?? 'Login failed');
      return false;
    }
  }

  Future<bool> register(User user, String password) async {
    setBusy();

    debugPrint('Registering user with email: ${user.email}');
    final result = await _apiService.register(user, password);

    if (result['success']) {
      debugPrint('Registration successful');
      setIdle();
      return true;
    } else {
      debugPrint('Registration failed: ${result['message']}');
      setError(result['message'] ?? 'Registration failed');
      return false;
    }
  }

  Future<void> logout() async {
    setBusy();
    await SharedPrefs.clearAll();
    _isLoggedIn = false;
    _userEmail = null;
    _userId = null; // Clear userId
    _token = null;
    setIdle();
  }

  // Method to get user details by ID
  Future<bool> getUserDetails() async {
    if (!_isLoggedIn || _token == null || _userId == null) {
      return false;
    }

    setBusy();
    final result = await _apiService.getUserById(_userId!, _token!);

    if (result['success']) {
      final userData = result['data'];
      _userEmail = userData['email'];

      await SharedPrefs.saveUserEmail(_userEmail!);

      setIdle();
      return true;
    } else {
      setError(result['message'] ?? 'Failed to get user details');
      return false;
    }
  }

  // Gửi yêu cầu quên mật khẩu
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    setBusy();

    final result = await _apiService.forgotPassword(email);

    if (result['success']) {
      setIdle();
      return result;
    } else {
      setError(result['message'] ?? 'Failed to send reset password request');
      return result;
    }
  }

  // Đặt lại mật khẩu
  Future<bool> resetPassword(String token, String newPassword) async {
    setBusy();

    final result = await _apiService.resetPassword(token, newPassword);

    if (result['success']) {
      setIdle();
      return true;
    } else {
      setError(result['message'] ?? 'Failed to reset password');
      return false;
    }
  }
}
