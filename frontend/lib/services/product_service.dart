// lib/services/product_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config/api_config.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/category.dart';

class ProductService {
  // Get all products
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.productsEndpoint}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        debugPrint('Failed to load products: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.productsEndpoint}?categories=$categoryId',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        debugPrint(
          'Failed to load products by category: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching products by category: $e');
      return [];
    }
  }

  // Get featured products
  Future<List<Product>> getFeaturedProducts({int count = 5}) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.productsEndpoint}/get/featured/$count',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        debugPrint('Failed to load featured products: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching featured products: $e');
      return [];
    }
  }

  // Get all categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.categoriesEndpoint}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        debugPrint('Failed to load categories: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.productsEndpoint}/$productId',
        ),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return Product.fromJson(data);
      } else {
        debugPrint('Failed to load product details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching product details: $e');
      return null;
    }
  }

  // Thêm phương thức này vào class ProductService
  Future<List<Product>> getRelatedProducts(
    String categoryId,
    List<String> excludeProductIds,
  ) async {
    try {
      debugPrint('Getting related products for category: $categoryId');
      debugPrint('Excluding products: $excludeProductIds');

      // Chuyển danh sách excludeProductIds thành chuỗi ngăn cách bởi dấu phẩy
      final excludeParam =
          excludeProductIds.isNotEmpty ? excludeProductIds.join(',') : '';

      final url =
          '${ApiConfig.baseUrl}${ApiConfig.productsEndpoint}/related/$categoryId';
      final fullUrl =
          excludeParam.isNotEmpty ? '$url?exclude=$excludeParam' : url;

      debugPrint('API URL: $fullUrl');

      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint('API response: $responseData');

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => Product.fromJson(json)).toList();
        } else {
          debugPrint('API returned success=false or no data');
          return [];
        }
      } else {
        debugPrint('Failed to load related products: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching related products: $e');
      return [];
    }
  }
}
