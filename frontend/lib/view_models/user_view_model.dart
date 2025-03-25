// lib/view_models/user_view_model.dart
import '../models/user.dart';
import '../services/user_service.dart';
import 'base_view_model.dart';

class UserViewModel extends BaseViewModel {
  final UserService _userService = UserService();
  User? _user;

  User? get user => _user;

  // Get user profile
  Future<bool> getUserProfile() async {
    setBusy();
    final result = await _userService.getUserProfile();

    if (result['success']) {
      _user = User.fromJson(result['data']);
      setIdle();
      return true;
    } else {
      setError(result['message'] ?? 'Failed to get user profile');
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(User updatedUser, {String? password}) async {
    setBusy();
    final result = await _userService.updateUserProfile(
      updatedUser,
      password: password,
    );

    if (result['success']) {
      _user = User.fromJson(result['data']);
      setIdle();
      return true;
    } else {
      setError(result['message'] ?? 'Failed to update user profile');
      return false;
    }
  }
}
