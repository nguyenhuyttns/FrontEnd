// lib/view_models/product_view_model.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import 'package:frontend/models/category.dart';
import '../services/product_service.dart';
import '../services/recommendation_service.dart';
import '../utils/navigation_service.dart';
import '../view_models/auth_view_model.dart';
import 'base_view_model.dart';

class ProductViewModel extends BaseViewModel {
  final ProductService _productService = ProductService();
  final RecommendationService _recommendationService = RecommendationService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Category> _categories = [];
  String _selectedCategoryId = ''; // Mặc định là tab "For Me"
  String _searchQuery = '';

  // Thêm thuộc tính để theo dõi thời gian xem
  DateTime? _productViewStartTime;
  String? _currentViewedProductId;

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

      // Add "All" category at the beginning (this will be our "For Me" tab)
      _categories.insert(
        0,
        Category(id: '', name: 'All', icon: 'all', color: '#6200EE'),
      );

      // Load all products but don't display them initially
      _products = await _productService.getProducts();

      // Tự động gọi API recommendations khi khởi tạo
      await loadRecommendations();

      setIdle();
    } catch (e) {
      debugPrint('Error in ProductViewModel.loadData: $e');
      setError('Failed to load products. Please try again.');
    }
  }

  // Phương thức mới để tải recommendations
  Future<void> loadRecommendations() async {
    // Đánh dấu tab "For Me" được chọn
    _selectedCategoryId = '';

    // Tải đề xuất
    await loadForMeRecommendations();

    // Thông báo UI cập nhật
    notifyListeners();
  }

  // Bắt đầu theo dõi thời gian xem sản phẩm
  void startProductView(String productId) {
    _productViewStartTime = DateTime.now();
    _currentViewedProductId = productId;
    debugPrint('Started tracking view for product: $productId');
  }

  // Kết thúc và ghi lại thời gian xem sản phẩm
  Future<void> endProductView() async {
    if (_productViewStartTime != null && _currentViewedProductId != null) {
      final viewDuration =
          DateTime.now().difference(_productViewStartTime!).inSeconds;
      await _recommendationService.trackProductView(
        _currentViewedProductId!,
        viewDuration,
      );

      debugPrint(
        'Tracked view for product: $_currentViewedProductId, duration: $viewDuration seconds',
      );

      _productViewStartTime = null;
      _currentViewedProductId = null;
    }
  }

  // Ghi lại thêm vào giỏ hàng
  Future<void> trackAddToCart(String productId) async {
    final result = await _recommendationService.trackAddToCart(productId);
    debugPrint('Tracked add to cart for product: $productId, success: $result');
  }

  // Ghi lại mua hàng
  Future<void> trackPurchase(String productId) async {
    final result = await _recommendationService.trackPurchase(productId);
    debugPrint('Tracked purchase for product: $productId, success: $result');
  }

  // Tải đề xuất "For Me"
  Future<void> loadForMeRecommendations() async {
    setBusy();

    try {
      // Kiểm tra xem người dùng đã đăng nhập chưa
      final authViewModel = Provider.of<AuthViewModel>(
        navigatorKey.currentContext!,
        listen: false,
      );

      if (!authViewModel.isLoggedIn) {
        // Nếu chưa đăng nhập, hiển thị màn hình trống với lời nhắc đăng nhập
        _filteredProducts = [];
        setIdle();
        return;
      }

      // Gọi API đề xuất
      _filteredProducts =
          await _recommendationService.getForMeRecommendations();

      if (_filteredProducts.isEmpty) {
        // Nếu không có đề xuất, hiển thị thông báo
        setError(
          'We\'re still learning your preferences. Browse more products to get personalized recommendations.',
        );
      }
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
      _filteredProducts = [];
      setError('An error occurred while loading recommendations');
    }

    setIdle();
  }

  void selectCategory(String categoryId) {
    setBusy();
    _selectedCategoryId = categoryId;

    // Nếu "For Me" được chọn
    if (categoryId.isEmpty) {
      loadForMeRecommendations(); // Tải đề xuất cá nhân hóa
    } else {
      // Các danh mục khác vẫn như cũ
      _applyFilters();
      setIdle();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;

    // Nếu đang ở "For Me" và có search query, vẫn giữ trang trống
    if (_selectedCategoryId.isEmpty) {
      _filteredProducts = [];
    } else {
      _applyFilters();
    }

    notifyListeners();
  }

  void _applyFilters() {
    // Chỉ áp dụng filter nếu không phải là "For Me"
    if (_selectedCategoryId.isEmpty) {
      _filteredProducts = [];
      return;
    }

    _filteredProducts =
        _products.where((product) {
          // Apply category filter
          bool matchesCategory = product.categoryId == _selectedCategoryId;

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
        // Nếu đang ở "For Me", tải lại đề xuất
        loadForMeRecommendations();
      } else {
        // Cho các danh mục khác, tải lại sản phẩm theo danh mục
        _products = await _productService.getProductsByCategory(
          _selectedCategoryId,
        );
        _applyFilters();
      }
    } catch (e) {
      debugPrint('Error refreshing products: $e');
      setError('Failed to refresh products. Please try again.');
    }
  }

  // Giữ các phương thức hiện có
  Product? _selectedProduct;
  bool _isLoadingProduct = false;
  bool _hasProductError = false;
  String _errorMessage = '';

  Product? get selectedProduct => _selectedProduct;
  bool get isLoadingProduct => _isLoadingProduct;
  bool get hasProductError => _hasProductError;
  @override
  String get errorMessage => _errorMessage;

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

  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      // Tải tất cả sản phẩm nếu chưa có
      if (_products.isEmpty) {
        _products = await _productService.getProducts();
      }

      // Lọc sản phẩm theo query
      return _products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase()) ||
            (product.brand.toLowerCase() ?? '').contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      debugPrint('Error searching products: $e');
      throw Exception('Failed to search products');
    }
  }
}
