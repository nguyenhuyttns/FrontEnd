import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class CartViewModel with ChangeNotifier {
  Map<String, CartItem> _items = {};
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
    } catch (error) {
      print('Error saving cart: $error');
    }
  }

  void addItem(
    String productId,
    double price,
    String name,
    String imageUrl,
    int quantity,
  ) {
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
        ),
      );
    }
    saveCart();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    saveCart();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (!_items.containsKey(productId)) return;

    if (quantity <= 0) {
      _items.remove(productId);
    } else {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          productId: existingCartItem.productId,
          name: existingCartItem.name,
          quantity: quantity,
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl,
        ),
      );
    }
    saveCart();
    notifyListeners();
  }

  void clear() {
    _items = {};
    saveCart();
    notifyListeners();
  }
}
