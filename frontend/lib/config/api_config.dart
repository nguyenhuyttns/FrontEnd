// lib/config/api_config.dart
class ApiConfig {
  // Update this to your actual API URL (including the /api/v1 part)
  static const String baseUrl =
      'http://192.168.1.216:3000/api/v1'; // For Android emulator
  // Use 'http://localhost:3000/api/v1' for iOS simulator
  // Use your actual server IP for physical devices

  static const String loginEndpoint = '/users/login';
  static const String registerEndpoint = '/users/register';
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';
  static const String ordersEndpoint = '/orders';
  static const String userEndpoint = '/users';
}
