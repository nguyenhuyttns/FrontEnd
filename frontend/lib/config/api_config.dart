// lib/config/api_config.dart
class ApiConfig {
  // Các endpoint hiện có
  static const String serverIP = '192.168.1.216';
  static const String baseUrl = 'http://$serverIP:3000/api/v1';

  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';
  static const String usersEndpoint = '/users';
  static const String ordersEndpoint = '/orders';
  static const String loginEndpoint = '/users/login';
  static const String registerEndpoint = '/users/register';
  static const String forgotPasswordEndpoint = '/users/forgot-password';
  static const String resetPasswordEndpoint = '/users/reset-password';

  // Thêm endpoints mới
  static const String userActivityEndpoint = '/user-activity';
  static const String recommendationsEndpoint = '/recommendations';

  // Phương thức hỗ trợ để sửa URL hình ảnh
  static String fixImageUrl(String url) {
    if (url.contains('localhost')) {
      return url.replaceAll('localhost', serverIP);
    }
    return url;
  }
}
