// lib/models/cart_item.dart
class CartItem {
  final String id;
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;
  final String categoryId; // Thêm trường này

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.categoryId, // Thêm trường này
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId, // Thêm trường này
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      name: json['name'],
      quantity: json['quantity'],
      price:
          json['price'] is int
              ? (json['price'] as int).toDouble()
              : json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      categoryId:
          json['categoryId'] ?? '', // Thêm trường này với giá trị mặc định
    );
  }
}
