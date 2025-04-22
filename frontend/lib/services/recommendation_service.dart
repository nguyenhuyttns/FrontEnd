// lib/services/recommendation_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product.dart';
import '../utils/shared_prefs.dart';

class RecommendationService {
  // Ghi lại lượt xem sản phẩm
  Future<bool> trackProductView(String productId, int viewTimeSeconds) async {
    try {
      final userId = await SharedPrefs.getUserId();
      final token = await SharedPrefs.getToken();

      if (userId == null || token == null) {
        return false; // Không thể track nếu chưa đăng nhập
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userActivityEndpoint}/view'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'productId': productId,
          'viewTime': viewTimeSeconds,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error tracking product view: $e');
      return false;
    }
  }

  // Ghi lại thêm vào giỏ hàng
  Future<bool> trackAddToCart(String productId) async {
    try {
      final userId = await SharedPrefs.getUserId();
      final token = await SharedPrefs.getToken();

      if (userId == null || token == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.userActivityEndpoint}/cart-add',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': userId, 'productId': productId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error tracking add to cart: $e');
      return false;
    }
  }

  // Ghi lại mua hàng
  Future<bool> trackPurchase(String productId) async {
    try {
      final userId = await SharedPrefs.getUserId();
      final token = await SharedPrefs.getToken();

      if (userId == null || token == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.userActivityEndpoint}/purchase',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userId': userId, 'productId': productId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error tracking purchase: $e');
      return false;
    }
  }

  // Lấy đề xuất "For Me"
  Future<List<Product>> getForMeRecommendations() async {
    try {
      final token = await SharedPrefs.getToken();

      if (token == null) {
        debugPrint('No token available for recommendations');
        return []; // Trả về danh sách trống nếu chưa đăng nhập
      }

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.recommendationsEndpoint}/for-me',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Recommendations response status: ${response.statusCode}');
      debugPrint('Recommendations response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] && data['products'] != null) {
          final List<dynamic> productsJson = data['products'];
          return productsJson.map((json) => Product.fromJson(json)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error getting recommendations: $e');
      return [];
    }
  }
}
