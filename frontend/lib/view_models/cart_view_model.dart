import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class CartViewModel with ChangeNotifier {
  Map<String, CartItem> _items = {};
  bool _isLoading = false;
  Map<String, String> _productCategories = {}; // Thêm map này để lưu categoryId

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

  // Getter để lấy categoryId
  String getCategoryId(String productId) {
    return _productCategories[productId] ?? '';
  }

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cartData');
      if (cartData != null) {
        final extractedData = json.decode(cartData) as Map<String, dynamic>;
        final Map<String, CartItem> loadedItems = {};
        extractedData.forEach((productId, itemData) {
          loadedItems[productId] = CartItem.fromJson(itemData);
        });
        _items = loadedItems;
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
      final cartData = {};
      _items.forEach((productId, item) {
        cartData[productId] = item.toJson();
      });
      prefs.setString('cartData', json.encode(cartData));

      // Lưu categoryIds
      prefs.setString('productCategories', json.encode(_productCategories));
    } catch (error) {
      print('Error saving cart: $error');
    }
  }

  void addItem(
    String productId,
    double price,
    String name,
    String imageUrl,
    String categoryId, { // Thêm tham số này
    int quantity = 1,
  }) {
    // Lưu categoryId vào map
    _productCategories[productId] = categoryId;

    if (_items.containsKey(productId)) {
      // Change quantity
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          productId: existingCartItem.productId,
          name: existingCartItem.name,
          quantity: existingCartItem.quantity + quantity,
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl,
          categoryId: categoryId, // Thêm categoryId
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          productId: productId,
          name: name,
          quantity: quantity,
          price: price,
          imageUrl: imageUrl,
          categoryId: categoryId, // Thêm categoryId
        ),
      );
    }
    saveCart();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    _productCategories.remove(productId); // Xóa cả categoryId
    saveCart();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (!_items.containsKey(productId)) return;

    if (quantity <= 0) {
      _items.remove(productId);
      _productCategories.remove(productId); // Xóa cả categoryId
    } else {
      final categoryId =
          _productCategories[productId] ?? ''; // Lấy categoryId hiện tại
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          productId: existingCartItem.productId,
          name: existingCartItem.name,
          quantity: quantity,
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl,
          categoryId: categoryId, // Thêm categoryId
        ),
      );
    }
    saveCart();
    notifyListeners();
  }

  void clear() {
    _items = {};
    _productCategories = {}; // Xóa cả map categoryId
    saveCart();
    notifyListeners();
  }
}
