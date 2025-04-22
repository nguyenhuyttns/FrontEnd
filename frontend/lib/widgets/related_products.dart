// lib/widgets/related_products.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import '../views/home/product_detail_screen.dart';

class RelatedProducts extends StatefulWidget {
  final String categoryId;
  final List<String> excludeProductIds;

  const RelatedProducts({
    super.key,
    required this.categoryId,
    required this.excludeProductIds,
  });

  @override
  State<RelatedProducts> createState() => _RelatedProductsState();
}

class _RelatedProductsState extends State<RelatedProducts> {
  final ProductService _productService = ProductService();
  bool _isLoading = false;
  List<Product> _relatedProducts = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadRelatedProducts();
  }

  @override
  void didUpdateWidget(RelatedProducts oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Tải lại nếu categoryId hoặc excludeProductIds thay đổi
    if (oldWidget.categoryId != widget.categoryId ||
        oldWidget.excludeProductIds.length != widget.excludeProductIds.length) {
      _loadRelatedProducts();
    }
  }

  Future<void> _loadRelatedProducts() async {
    if (widget.categoryId.isEmpty) {
      debugPrint('Empty categoryId, skipping related products fetch');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      debugPrint('Loading related products for category: ${widget.categoryId}');
      debugPrint('Excluding products: ${widget.excludeProductIds}');

      final products = await _productService.getRelatedProducts(
        widget.categoryId,
        widget.excludeProductIds,
      );

      debugPrint('Loaded ${products.length} related products');

      if (mounted) {
        setState(() {
          _relatedProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading related products: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error.isNotEmpty) {
      debugPrint('Error in RelatedProducts: $_error');
      return const SizedBox.shrink(); // Ẩn nếu có lỗi
    }

    if (_relatedProducts.isEmpty) {
      debugPrint('No related products found');
      return const SizedBox.shrink(); // Ẩn nếu không có sản phẩm liên quan
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'Related Products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _relatedProducts.length,
            itemBuilder: (context, index) {
              final product = _relatedProducts[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ProductDetailScreen(productId: product.id),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
