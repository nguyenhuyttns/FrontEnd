// lib/views/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/views/carts/cart_screen.dart';
import 'package:frontend/views/profile/profile_screen.dart';
import 'package:frontend/views/search/search_screen.dart';
import 'package:frontend/views/wallet/wallet_screen.dart';
import 'package:frontend/widgets/product_card.dart';
import 'package:provider/provider.dart';
import '../../view_models/product_view_model.dart';
import '../../view_models/auth_view_model.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // Thêm đoạn code này để tự động chọn tab "For Me" và gọi API khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productViewModel = Provider.of<ProductViewModel>(
        context,
        listen: false,
      );

      // Đặt selectedCategoryId thành rỗng (tương ứng với tab "For Me")
      productViewModel.selectCategory('');

      // Tải dữ liệu đề xuất
      productViewModel.loadRecommendations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on Home
        break;
      case 1:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const CartScreen()));
        break;
      case 2:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const WalletScreen()));
        break;
      case 3:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
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
                  // App Bar with Title
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.shopping_bag,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'E-Shop',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_outlined),
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.logout),
                        ),
                        tooltip: 'Logout',
                        onPressed: () {
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
                                      final authViewModel =
                                          Provider.of<AuthViewModel>(
                                            context,
                                            listen: false,
                                          );
                                      await authViewModel.logout();
                                      Navigator.of(context).pop();
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
                      const SizedBox(width: 8),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(66),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _buildSearchBar(productViewModel),
                      ),
                    ),
                  ),

                  // Section Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),

                  // Categories
                  SliverToBoxAdapter(child: _buildCategories(productViewModel)),

                  // Products Section Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Products',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // View all products functionality
                            },
                            child: Text(
                              'View All',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

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
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (productViewModel.products.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Hiển thị nội dung khác nhau tùy thuộc vào tab đang chọn
                            if (productViewModel.selectedCategoryId.isEmpty)
                              // Tab "For Me"
                              _buildForMeEmptyState(context, productViewModel)
                            else
                              // Tab danh mục khác
                              const Text(
                                'No products found in this category.',
                                style: TextStyle(fontSize: 16),
                              ),
                          ],
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
                          return ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailScreen(
                                        productId: product.id,
                                      ),
                                ),
                              );
                            },
                          );
                        }, childCount: productViewModel.products.length),
                      ),
                    ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Colors.grey,
                elevation: 8,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(ProductViewModel productViewModel) {
    return GestureDetector(
      onTap: () {
        // Navigate to search screen when search bar is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => SearchScreen(initialQuery: _searchController.text),
          ),
        );
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Icon(Icons.search, color: Colors.grey[500]),
            ),
            Expanded(
              child: Text(
                'Search products...',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(ProductViewModel productViewModel) {
    // Calculate fixed width for all category tabs
    // This will make all tabs the same width regardless of text length
    final double fixedWidth = 110.0;

    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: productViewModel.categories.length,
        itemBuilder: (context, index) {
          final category = productViewModel.categories[index];
          final isSelected = category.id == productViewModel.selectedCategoryId;

          // Check if this is the first category (index 0) which is typically "All"
          final isFirstCategory = index == 0;

          // Display "For Me" instead of "All" for the first category
          final buttonText = isFirstCategory ? 'For Me' : category.name;

          return Container(
            width: fixedWidth, // Fixed width for all tabs
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => productViewModel.selectCategory(category.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color:
                          isSelected
                              ? Colors.white
                              : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis, // Handle long text
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForMeEmptyState(
    BuildContext context,
    ProductViewModel productViewModel,
  ) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    if (!authViewModel.isLoggedIn) {
      // Trạng thái khi chưa đăng nhập
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sign in for Personalized Recommendations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Create an account or sign in to get product recommendations based on your interests.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Sign In'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/register');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Register'),
              ),
            ],
          ),
        ],
      );
    } else if (productViewModel.isError) {
      // Trạng thái khi đã đăng nhập nhưng chưa có đề xuất
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: Colors.amber[700],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'We\'re Learning Your Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Browse and shop more products to help us understand your preferences better.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Chuyển người dùng đến danh mục phổ biến
              if (productViewModel.categories.length > 1) {
                productViewModel.selectCategory(
                  productViewModel.categories[1].id,
                );
              }
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explore Products'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      );
    } else {
      // Trạng thái đang tải
      return const Center(child: CircularProgressIndicator());
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
