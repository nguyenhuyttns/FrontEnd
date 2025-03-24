// lib/views/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/config/api_config.dart';
import 'package:frontend/views/carts/cart_screen.dart';
import 'package:frontend/views/profile/profile_screen.dart';
import 'package:frontend/views/wallet/wallet_screen.dart';
import 'package:provider/provider.dart';
import '../../view_models/product_view_model.dart';
import '../../models/product.dart';
import 'product_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../view_models/auth_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0; // Thêm biến để theo dõi tab đang được chọn

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Chuyển đến màn hình tương ứng
    switch (index) {
      case 0:
        // Đã ở Home, không cần làm gì
        break;
      case 1:
        // Chuyển đến Cart
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => CartScreen()));
        break;
      case 2:
        // Chuyển đến Wallet
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => WalletScreen()));
        break;
      case 3:
        // Chuyển đến Profile
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, productViewModel, _) {
        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => productViewModel.refreshProducts(),
              child: CustomScrollView(
                slivers: [
                  // App Bar with Title - Fixed to prevent overflow
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    title: Row(
                      children: [
                        Icon(
                          Icons.shopping_bag,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ShopEase',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      // Notification Icon
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                      ),
                      // Logout Button
                      IconButton(
                        icon: const Icon(Icons.logout),
                        tooltip: 'Logout',
                        onPressed: () {
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Logout'),
                                content: const Text(
                                  'Are you sure you want to logout?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: const Text('CANCEL'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      // Thực hiện đăng xuất thông qua AuthViewModel
                                      final authViewModel =
                                          Provider.of<AuthViewModel>(
                                            context,
                                            listen: false,
                                          );
                                      await authViewModel.logout();

                                      // Đóng dialog
                                      Navigator.of(context).pop();

                                      // Điều hướng về màn hình đăng nhập
                                      Navigator.of(
                                        context,
                                      ).pushReplacementNamed('/login');
                                    },
                                    child: const Text('LOGOUT'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                    // Sửa lỗi tràn bố cục bằng cách tăng preferredSize và điều chỉnh padding
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(
                        66,
                      ), // Tăng chiều cao lên
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _buildSearchBar(productViewModel),
                      ),
                    ),
                  ),

                  // Categories
                  SliverToBoxAdapter(child: _buildCategories(productViewModel)),

                  // Products
                  if (productViewModel.isBusy)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (productViewModel.isError)
                    SliverFillRemaining(
                      child: Center(
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
                              onPressed: () => productViewModel.loadData(),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (productViewModel.products.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No products found.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = productViewModel.products[index];
                          return _buildProductCard(context, product);
                        }, childCount: productViewModel.products.length),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Thêm Bottom Navigation Bar
          bottomNavigationBar: BottomNavigationBar(
            type:
                BottomNavigationBarType
                    .fixed, // Để hiển thị nhãn cho tất cả các tab
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                label: 'Wallet',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(ProductViewModel productViewModel) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: productViewModel.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      productViewModel.setSearchQuery('');
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCategories(ProductViewModel productViewModel) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: productViewModel.categories.length,
        itemBuilder: (context, index) {
          final category = productViewModel.categories[index];
          final isSelected = category.id == productViewModel.selectedCategoryId;

          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => productViewModel.selectCategory(category.id),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : _getCategoryColor(category.color),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : null,
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(category.name),
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black,
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

  Widget _buildProductCard(BuildContext context, Product product) {
    String imageUrl = ApiConfig.fixImageUrl(product.image);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      errorWidget: (context, url, error) {
                        print('Error loading image: $url, Error: $error');
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                    if (product.countInStock <= 0)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: Text(
                            'OUT OF STOCK',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        '${product.rating}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${product.numReviews})',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.add_shopping_cart,
                            size: 18,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Add to cart functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
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
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'all':
        return Icons.apps;
      case 'electronics':
        return Icons.devices;
      case 'home':
        return Icons.home;
      case 'health':
        return Icons.health_and_safety;
      case 'fashion':
        return Icons.checkroom;
      case 'beauty':
        return Icons.face;
      case 'sports':
        return Icons.sports_soccer;
      case 'books':
        return Icons.book;
      case 'toys':
        return Icons.toys;
      case 'food':
        return Icons.fastfood;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String colorHex) {
    try {
      if (colorHex.startsWith('#')) {
        return Color(int.parse('0xFF${colorHex.substring(1)}'));
      }
      return Colors.grey;
    } catch (e) {
      return Colors.grey;
    }
  }
}
