import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};
  Map<String, String> _productCategories =
      {}; // Map lưu productId -> categoryId
  bool _isLoading = false;

  Map<String, CartItem> get items {
    return {..._items};
  }

  bool get isLoading => _isLoading;

  int get itemCount {
    return _items.length;
  }

  int get totalQuantity {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Getter để lấy categoryId từ map
  String getCategoryId(String productId) {
    return _productCategories[productId] ?? '';
  }

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Tải items
      final String? cartItemsJson = prefs.getString('cartItems');
      if (cartItemsJson != null) {
        final Map<String, dynamic> cartData = json.decode(cartItemsJson);
        _items = {};
        cartData.forEach((productId, itemData) {
          // Đảm bảo itemData có đủ các trường cần thiết
          itemData['productId'] = productId; // Thêm productId vào dữ liệu
          itemData['categoryId'] =
              _productCategories[productId] ?? ''; // Thêm categoryId

          _items[productId] = CartItem.fromJson(itemData); // Sử dụng fromJson
        });
      }

      // Tải categoryIds
      final String? categoriesJson = prefs.getString('productCategories');
      if (categoriesJson != null) {
        final Map<String, dynamic> categoriesData = json.decode(categoriesJson);
        _productCategories = {};
        categoriesData.forEach((productId, categoryId) {
          _productCategories[productId] = categoryId as String;
        });
      }
    } catch (error) {
      // Handle error
      print('Error loading cart: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Lưu items
      final cartData = {};
      _items.forEach((productId, item) {
        // Sử dụng phương thức toJson có sẵn
        cartData[productId] = item.toJson();
      });
      await prefs.setString('cartItems', json.encode(cartData));

      // Lưu categoryIds
      await prefs.setString(
        'productCategories',
        json.encode(_productCategories),
      );
    } catch (error) {
      print('Error saving cart: $error');
    }
  }

  void addItem(
    String productId,
    double price,
    String name,
    String imageUrl,
    String categoryId, {
    int quantity = 1,
  }) {
    // Lưu categoryId vào map riêng
    _productCategories[productId] = categoryId;

    if (_items.containsKey(productId)) {
      // Cập nhật số lượng
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          productId: productId, // Thêm trường này
          name: existingCartItem.name,
          quantity: existingCartItem.quantity + quantity,
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl,
          categoryId: categoryId, // Thêm trường này
        ),
      );
    } else {
      // Thêm mới vào giỏ hàng
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          productId: productId, // Thêm trường này
          name: name,
          quantity: quantity,
          price: price,
          imageUrl: imageUrl,
          categoryId: categoryId, // Thêm trường này
        ),
      );
    }
    saveCart(); // Lưu giỏ hàng
    notifyListeners();
  }

  void clear() {
    _items = {};
    _productCategories = {}; // Xóa cả map categoryId
    saveCart();
    notifyListeners();
  }
}
