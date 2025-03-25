// lib/models/order.dart
import 'package:frontend/config/api_config.dart';

class OrderItem {
  final String id;
  final int quantity;
  final Product product;

  OrderItem({required this.id, required this.quantity, required this.product});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id'],
      quantity: json['quantity'],
      product: Product.fromJson(json['product']),
    );
  }
}

class Product {
  final String id;
  final String name;
  final String image;
  final double price;
  final Category category;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      image: ApiConfig.fixImageUrl(json['image']),
      price:
          (json['price'] is int)
              ? (json['price'] as int).toDouble()
              : json['price'].toDouble(),
      category: Category.fromJson(json['category']),
    );
  }
}

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['_id'], name: json['name']);
  }
}

class Order {
  final String id;
  final List<OrderItem> orderItems;
  final String shippingAddress1;
  final String shippingAddress2;
  final String city;
  final String zip;
  final String country;
  final String phone;
  final String status;
  final double totalPrice;
  final String userId;
  final DateTime dateOrdered;

  Order({
    required this.id,
    required this.orderItems,
    required this.shippingAddress1,
    required this.shippingAddress2,
    required this.city,
    required this.zip,
    required this.country,
    required this.phone,
    required this.status,
    required this.totalPrice,
    required this.userId,
    required this.dateOrdered,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      orderItems:
          (json['orderItems'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList(),
      shippingAddress1: json['shippingAddress1'],
      shippingAddress2: json['shippingAddress2'],
      city: json['city'],
      country: json['country'],
      zip: json['zip'],
      phone: json['phone'],
      status: json['status'],
      totalPrice:
          (json['totalPrice'] is int)
              ? (json['totalPrice'] as int).toDouble()
              : json['totalPrice'].toDouble(),
      userId: json['user'],
      dateOrdered: DateTime.parse(json['dateOrdered']),
    );
  }
}
