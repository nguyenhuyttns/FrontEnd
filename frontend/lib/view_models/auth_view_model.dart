// lib/view_models/auth_view_model.dart
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/shared_prefs.dart';
import 'base_view_model.dart';

class AuthViewModel extends BaseViewModel {
  final ApiService _apiService = ApiService();
  String? _userEmail;
  bool _isLoggedIn = false;
  String? _token; // Add this to store the token

  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token; // Getter for token

  AuthViewModel() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    setBusy();
    _isLoggedIn = await SharedPrefs.isLoggedIn();
    if (_isLoggedIn) {
      _userEmail = await SharedPrefs.getUserEmail();
      _token = await SharedPrefs.getToken(); // Get stored token
      debugPrint('Retrieved stored token: $_token');
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

      // Print the token to console
      debugPrint('==================== LOGIN TOKEN ====================');
      debugPrint('Token: $token');
      debugPrint('=====================================================');

      await SharedPrefs.saveToken(token);
      await SharedPrefs.saveUserEmail(data['user']);
      _userEmail = data['user'];
      _token = token; // Store token in view model
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
    _token = null; // Clear token
    setIdle();
  }
}
