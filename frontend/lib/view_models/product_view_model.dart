// lib/view_models/product_view_model.dart
import 'package:flutter/material.dart';

import '../models/product.dart';
import 'package:frontend/models/category.dart';
import '../services/product_service.dart';
import 'base_view_model.dart';

class ProductViewModel extends BaseViewModel {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Category> _categories = [];
  String _selectedCategoryId = '';
  String _searchQuery = '';

  List<Product> get products => _filteredProducts;
  List<Category> get categories => _categories;
  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  ProductViewModel() {
    loadData();
  }

  Future<void> loadData() async {
    setBusy();

    try {
      // Load categories first
      _categories = await _productService.getCategories();

      // Add "All" category at the beginning
      _categories.insert(
        0,
        Category(id: '', name: 'All', icon: 'all', color: '#6200EE'),
      );

      // Load all products
      _products = await _productService.getProducts();
      _filteredProducts = List.from(_products);

      setIdle();
    } catch (e) {
      debugPrint('Error in ProductViewModel.loadData: $e');
      setError('Failed to load products. Please try again.');
    }
  }

  void selectCategory(String categoryId) {
    setBusy();
    _selectedCategoryId = categoryId;
    _applyFilters();
    setIdle();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredProducts =
        _products.where((product) {
          // Apply category filter
          bool matchesCategory =
              _selectedCategoryId.isEmpty ||
              product.categoryId == _selectedCategoryId;

          // Apply search filter
          bool matchesSearch =
              _searchQuery.isEmpty ||
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );

          return matchesCategory && matchesSearch;
        }).toList();

    notifyListeners();
  }

  Future<void> refreshProducts() async {
    try {
      if (_selectedCategoryId.isEmpty) {
        _products = await _productService.getProducts();
      } else {
        _products = await _productService.getProductsByCategory(
          _selectedCategoryId,
        );
      }
      _applyFilters();
    } catch (e) {
      debugPrint('Error refreshing products: $e');
      setError('Failed to refresh products. Please try again.');
    }
  }

  // Add these properties to your ProductViewModel class
  Product? _selectedProduct;
  bool _isLoadingProduct = false;
  bool _hasProductError = false;
  String _errorMessage = '';

  // Add these getters
  Product? get selectedProduct => _selectedProduct;
  bool get isLoadingProduct => _isLoadingProduct;
  bool get hasProductError => _hasProductError;
  @override
  String get errorMessage => _errorMessage;

  // Add this method to fetch product details
  Future<void> getProductById(String productId) async {
    _isLoadingProduct = true;
    _hasProductError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      final product = await _productService.getProductById(productId);

      if (product != null) {
        _selectedProduct = product;
      } else {
        _hasProductError = true;
        _errorMessage = 'Product not found';
      }
    } catch (e) {
      _hasProductError = true;
      _errorMessage = 'Failed to load product details';
      debugPrint('Error in getProductById: $e');
    } finally {
      _isLoadingProduct = false;
      notifyListeners();
    }
  }
}
