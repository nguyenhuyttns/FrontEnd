// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/provider/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/view_models/auth_view_model.dart';
import 'package:frontend/services/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final OrderService _orderService = OrderService();

  // Form fields
  final _addressController = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      // Check if user is logged in
      if (!authViewModel.isLoggedIn) {
        throw Exception("User not logged in");
      }

      // Get user ID - Make sure to store user ID in your AuthViewModel
      final userId = authViewModel.userId;

      if (userId == null || userId.isEmpty) {
        throw Exception("User ID not available");
      }

      // Debug
      print('User ID: $userId');
      print('Auth Token: ${authViewModel.token}');

      // Prepare order items
      final orderItems =
          cartProvider.items.entries.map((entry) {
            return {
              "quantity": entry.value.quantity,
              "product": entry.key, // Assuming entry.key is the product ID
            };
          }).toList();

      // Prepare order data
      final orderData = {
        "orderItems": orderItems,
        "shippingAddress1": _addressController.text,
        "shippingAddress2": _address2Controller.text,
        "city": _cityController.text,
        "zip": _zipController.text,
        "country": _countryController.text,
        "phone": _phoneController.text,
        "user": userId, // Using ID instead of email
      };

      // Place order using the order service
      final result = await _orderService.placeOrder(
        orderData,
        authViewModel.token ?? '',
      );

      if (result['success']) {
        // Order placed successfully
        cartProvider.clear();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        // Handle error
        throw Exception(result['message'] ?? 'Failed to place order');
      }
    } catch (error) {
      // Show error message
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      print('Error details: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const Text(
                        'Shipping Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _address2Controller,
                        decoration: const InputDecoration(
                          labelText: 'Address 2 (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your city';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _zipController,
                        decoration: const InputDecoration(
                          labelText: 'ZIP Code',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your ZIP code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _countryController,
                        decoration: const InputDecoration(
                          labelText: 'Country',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your country';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...cart.items.entries.map((entry) {
                        final item = entry.value;
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text('${item.quantity} x \$${item.price}'),
                          trailing: Text(
                            '\$${(item.quantity * item.price).toStringAsFixed(2)}',
                          ),
                        );
                      }),
                      const Divider(),
                      ListTile(
                        title: const Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          '\$${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: cart.items.isEmpty ? null : _placeOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text(
                            'PLACE ORDER',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
