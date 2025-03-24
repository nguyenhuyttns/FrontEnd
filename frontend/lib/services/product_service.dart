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
}
