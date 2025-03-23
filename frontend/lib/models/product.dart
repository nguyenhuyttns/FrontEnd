// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final String description;
  final String richDescription;
  final String image;
  final List<String> images;
  final String brand;
  final double price;
  final String categoryId;
  final String categoryName;
  final int countInStock;
  final double rating;
  final int numReviews;
  final bool isFeatured;
  final DateTime dateCreated;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.richDescription,
    required this.image,
    required this.images,
    required this.brand,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    required this.countInStock,
    required this.rating,
    required this.numReviews,
    required this.isFeatured,
    required this.dateCreated,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      richDescription: json['richDescription'] ?? '',
      image: json['image'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      brand: json['brand'] ?? '',
      price: json['price'] != null ? json['price'].toDouble() : 0.0,
      categoryId:
          json['category'] != null && json['category'] is Map
              ? json['category']['id'] ?? ''
              : json['category'] ?? '',
      categoryName:
          json['category'] != null && json['category'] is Map
              ? json['category']['name'] ?? ''
              : '',
      countInStock: json['countInStock'] ?? 0,
      rating: json['rating'] != null ? json['rating'].toDouble() : 0.0,
      numReviews: json['numReviews'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
      dateCreated:
          json['dateCreated'] != null
              ? DateTime.parse(json['dateCreated'])
              : DateTime.now(),
    );
  }
}
