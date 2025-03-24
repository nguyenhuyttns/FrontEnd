class CartItem {
  final String id;
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
    );
  }
}
