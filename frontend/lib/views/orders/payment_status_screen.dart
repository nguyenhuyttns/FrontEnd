// lib/views/orders/payment_status_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/provider/cart_provider.dart';
import 'package:frontend/view_models/payment_view_model.dart';
import 'package:frontend/views/orders/order_success_screen.dart';

class PaymentStatusScreen extends StatefulWidget {
  final String orderId;
  final String? paymentId;

  const PaymentStatusScreen({super.key, required this.orderId, this.paymentId});

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  bool _isChecking = true;
  bool _isSuccess = false;
  String _message = 'Đang kiểm tra trạng thái thanh toán...';

  @override
  void initState() {
    super.initState();
    _checkPaymentStatus();
  }

  Future<void> _checkPaymentStatus() async {
    final paymentViewModel = Provider.of<PaymentViewModel>(
      context,
      listen: false,
    );

    try {
      // Xử lý thanh toán
      final success = await paymentViewModel.processPayment(
        widget.orderId,
        "0",
      );

      setState(() {
        _isChecking = false;
        _isSuccess = success;
        _message =
            success
                ? 'Thanh toán thành công!'
                : 'Thanh toán thất bại. Vui lòng thử lại hoặc chọn phương thức thanh toán khác.';
      });

      if (success) {
        // Xóa giỏ hàng
        Provider.of<CartProvider>(context, listen: false).clear();

        // Chuyển đến màn hình thành công sau 2 giây
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const OrderSuccessScreen(),
              ),
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      setState(() {
        _isChecking = false;
        _isSuccess = false;
        _message = 'Lỗi: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trạng thái thanh toán'), elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isChecking)
                const CircularProgressIndicator()
              else
                Icon(
                  _isSuccess ? Icons.check_circle : Icons.error,
                  color: _isSuccess ? Colors.green : Colors.red,
                  size: 80,
                ),
              const SizedBox(height: 24),
              Text(
                _message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (!_isChecking && !_isSuccess)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Quay lại'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
