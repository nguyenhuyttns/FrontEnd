// lib/views/home/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/provider/cart_provider.dart';
import 'package:frontend/views/carts/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/config/api_config.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/view_models/product_view_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Load product details when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductViewModel>(
        context,
        listen: false,
      ).getProductById(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, productViewModel, _) {
        final product = productViewModel.selectedProduct;
        final isLoading = productViewModel.isLoadingProduct;
        final hasError = productViewModel.hasProductError;

        return Scaffold(
          appBar: AppBar(
            title: Text(product?.name ?? 'Product Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share functionality coming soon'),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
            ],
          ),
          body:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          productViewModel.errorMessage,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed:
                              () => productViewModel.getProductById(
                                widget.productId,
                              ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                  : product == null
                  ? const Center(child: Text('Product not found'))
                  : _buildProductDetails(context, product),
          bottomNavigationBar:
              isLoading || hasError || product == null
                  ? null
                  : _buildBottomBar(context, product),
        );
      },
    );
  }

  Widget _buildProductDetails(BuildContext context, Product product) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Hero(
            tag: 'product_image_${product.id}',
            child: CachedNetworkImage(
              imageUrl: ApiConfig.fixImageUrl(product.image),
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 100),
                  ),
            ),
          ),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Brand and Rating
                Row(
                  children: [
                    if (product.brand.isNotEmpty) ...[
                      Text(
                        'Brand: ${product.brand}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' (${product.numReviews} reviews)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Stock Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        product.countInStock > 0
                            ? Colors.green[100]
                            : Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.countInStock > 0
                        ? 'In Stock: ${product.countInStock}'
                        : 'Out of Stock',
                    style: TextStyle(
                      color:
                          product.countInStock > 0
                              ? Colors.green[800]
                              : Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),

                if (product.richDescription.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.richDescription,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Additional Info
                if (product.isFeatured)
                  Chip(
                    label: const Text('Featured Product'),
                    backgroundColor: Colors.amber[100],
                    labelStyle: TextStyle(color: Colors.amber[800]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Quantity Selector
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed:
                      _quantity > 1
                          ? () {
                            setState(() {
                              _quantity--;
                            });
                          }
                          : null,
                  color: _quantity > 1 ? Colors.black : Colors.grey,
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed:
                      _quantity < product.countInStock
                          ? () {
                            setState(() {
                              _quantity++;
                            });
                          }
                          : null,
                  color:
                      _quantity < product.countInStock
                          ? Colors.black
                          : Colors.grey,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Add to Cart Button
          Expanded(
            child: ElevatedButton(
              onPressed:
                  product.countInStock > 0
                      ? () {
                        // Add to cart functionality - modified for CartProvider
                        for (int i = 0; i < _quantity; i++) {
                          cartProvider.addItem(
                            product.id,
                            product.price,
                            product.name,
                            ApiConfig.fixImageUrl(product.image),
                          );
                        }

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$_quantity ${product.name} added to cart',
                            ),
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'VIEW CART',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const CartScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'ADD TO CART',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
