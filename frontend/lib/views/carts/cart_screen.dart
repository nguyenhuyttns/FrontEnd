// lib/views/carts/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/provider/cart_provider.dart';
import 'package:frontend/views/orders/checkout_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/api_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/widgets/cart_item_widget.dart'; // Import your enhanced CartItemWidget
import 'package:frontend/widgets/related_products.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Shopping Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Consumer<CartProvider>(
            builder: (ctx, cartProvider, _) {
              if (cartProvider.items.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Clear Cart',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text('Clear Cart'),
                          content: const Text(
                            'Are you sure you want to remove all items from your cart?',
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          actions: [
                            TextButton(
                              child: const Text('CANCEL'),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('CLEAR'),
                              onPressed: () {
                                Provider.of<CartProvider>(
                                  context,
                                  listen: false,
                                ).clear();
                                Navigator.of(ctx).pop();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Cart has been cleared',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (ctx, cartProvider, _) {
          if (cartProvider.items.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              // Cart summary card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_cart,
                        color: theme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${cartProvider.itemCount} ${cartProvider.itemCount == 1 ? 'Item' : 'Items'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'in your cart',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Cart items list
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.items.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (ctx, i) {
                    final productId = cartProvider.items.keys.toList()[i];
                    final item = cartProvider.items.values.toList()[i];

                    // If you've created the enhanced CartItemWidget, use it:
                    return CartItemWidget(productId: productId, item: item);

                    // Otherwise, use this enhanced inline implementation:
                    /*
                    return Dismissible(
                      key: ValueKey(productId),
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 26,
                            ),
                          ],
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) {
                        return showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Remove Item'),
                            content: Text(
                              'Are you sure you want to remove ${item.name} from your cart?',
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            actions: [
                              TextButton(
                                child: const Text('No'),
                                onPressed: () => Navigator.of(ctx).pop(false),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Yes'),
                                onPressed: () => Navigator.of(ctx).pop(true),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        cartProvider.removeItem(productId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} removed from cart'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                cartProvider.addItem(
                                  productId,
                                  item.price,
                                  item.name,
                                  item.imageUrl,
                                );
                                
                                // If quantity was more than 1, add it multiple times
                                for (int i = 1; i < item.quantity; i++) {
                                  cartProvider.addItem(
                                    productId,
                                    item.price,
                                    item.name,
                                    item.imageUrl,
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: ApiConfig.fixImageUrl(item.imageUrl),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[100],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey[100],
                                      child: const Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 16),
                              
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product Name
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    
                                    const SizedBox(height: 8),
                                    
                                    // Price
                                    Row(
                                      children: [
                                        Text(
                                          '\$${item.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          ' each',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    // Quantity Controls and Total
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Quantity Controls
                                        Container(
                                          height: 36,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey[300]!),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              // Decrease Button
                                              InkWell(
                                                onTap: () {
                                                  if (item.quantity > 1) {
                                                    cartProvider.removeSingleItem(productId);
                                                  } else {
                                                    // Show delete confirmation when trying to reduce below 1
                                                    showDialog(
                                                      context: context,
                                                      builder: (ctx) => AlertDialog(
                                                        title: const Text('Remove Item'),
                                                        content: Text(
                                                          'Do you want to remove ${item.name} from your cart?',
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(16),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            child: const Text('No'),
                                                            onPressed: () {
                                                              Navigator.of(ctx).pop(false);
                                                            },
                                                          ),
                                                          TextButton(
                                                            style: TextButton.styleFrom(
                                                              foregroundColor: Colors.red,
                                                            ),
                                                            child: const Text('Yes'),
                                                            onPressed: () {
                                                              Navigator.of(ctx).pop(true);
                                                              cartProvider.removeItem(productId);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                },
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(7),
                                                  bottomLeft: Radius.circular(7),
                                                ),
                                                child: Container(
                                                  width: 32,
                                                  height: 36,
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.remove,
                                                    size: 16,
                                                    color: item.quantity > 1 ? Colors.black : Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              
                                              // Quantity Display
                                              Container(
                                                width: 32,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '${item.quantity}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              
                                              // Increase Button
                                              InkWell(
                                                onTap: () {
                                                  cartProvider.addItem(
                                                    productId,
                                                    item.price,
                                                    item.name,
                                                    item.imageUrl,
                                                  );
                                                },
                                                borderRadius: const BorderRadius.only(
                                                  topRight: Radius.circular(7),
                                                  bottomRight: Radius.circular(7),
                                                ),
                                                child: Container(
                                                  width: 32,
                                                  height: 36,
                                                  alignment: Alignment.center,
                                                  child: const Icon(
                                                    Icons.add,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // Total Price
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: theme.primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    */
                  },
                ),
              ),
              _buildRelatedProductsSection(cartProvider),
            ],
          );
        },
      ),
      // Thay thế phần bottomNavigationBar trong CartScreen
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (ctx, cartProvider, _) {
          if (cartProvider.items.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ), // Giảm padding
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), // Giảm border radius
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 6, // Giảm blur
                  offset: const Offset(0, -3), // Giảm offset
                ),
              ],
            ),
            child: SafeArea(
              // Sử dụng maintainBottomViewPadding để tránh bị che bởi thanh navigation của điện thoại
              maintainBottomViewPadding: true,
              // Sử dụng minimum để giảm thiểu padding khi không cần thiết
              minimum: const EdgeInsets.only(bottom: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pricing details - Sử dụng Row với mainAxisSize.min để tiết kiệm không gian
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cột bên trái chứa labels
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subtotal:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Shipping:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Cột bên phải chứa values
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'FREE',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12), // Giảm khoảng cách
                  // Checkout button - Giảm chiều cao
                  SizedBox(
                    width: double.infinity,
                    height: 48, // Giảm chiều cao button
                    child: ElevatedButton(
                      onPressed:
                          cartProvider.items.isEmpty
                              ? null
                              : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => const CheckoutScreen(),
                                  ),
                                );
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Giảm border radius
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ), // Giảm padding
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'CHECKOUT', // Rút gọn text
                            style: TextStyle(
                              fontSize: 14, // Giảm font size
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5, // Giảm letter spacing
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            size: 14,
                          ), // Giảm icon size
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRelatedProductsSection(CartProvider cartProvider) {
    if (cartProvider.items.isEmpty) {
      return const SizedBox.shrink();
    }

    // Lấy danh sách categoryIds từ các sản phẩm trong giỏ hàng
    final Set<String> categoryIds = {};
    final List<String> productIds = [];

    cartProvider.items.forEach((productId, cartItem) {
      // Thêm productId vào danh sách cần loại trừ
      productIds.add(productId);

      // Sử dụng getCategoryId thay vì truy cập trực tiếp
      final categoryId = cartProvider.getCategoryId(productId);
      if (categoryId.isNotEmpty) {
        categoryIds.add(categoryId);
      }
    });

    // Nếu không có categoryId nào, không hiển thị gợi ý
    if (categoryIds.isEmpty) {
      debugPrint('No category IDs found in cart items');
      return const SizedBox.shrink();
    }

    // Lấy categoryId đầu tiên để gợi ý
    final firstCategoryId = categoryIds.first;
    debugPrint(
      'Using first category ID for related products: $firstCategoryId',
    );

    return Column(
      children: [
        const Divider(height: 32, thickness: 1, indent: 16, endIndent: 16),
        RelatedProducts(
          categoryId: firstCategoryId,
          excludeProductIds: productIds,
        ),
        const SizedBox(height: 16), // Thêm khoảng cách phía dưới
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Looks like you haven\'t added any items to your cart yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start Shopping',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
