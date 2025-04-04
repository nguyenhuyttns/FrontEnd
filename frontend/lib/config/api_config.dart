// lib/config/api_config.dart
class ApiConfig {
  // Update this to your actual API URL (including the /api/v1 part)
  static const String serverIP = 'localhost';
  static const String baseUrl = 'http://$serverIP:3000/api/v1';

  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';
  static const String usersEndpoint = '/users';
  static const String ordersEndpoint = '/orders';
  static const String loginEndpoint = '/users/login';
  static const String registerEndpoint = '/users/register';

  // Thêm endpoints mới cho tính năng quên mật khẩu
  static const String forgotPasswordEndpoint = '/users/forgot-password';
  static const String resetPasswordEndpoint = '/users/reset-password';

  // Phương thức hỗ trợ để sửa URL hình ảnh
  static String fixImageUrl(String url) {
    if (url.contains('localhost')) {
      return url.replaceAll('localhost', serverIP);
    }
    return url;
  }
}
