// lib/views/orders/payment_method_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/view_models/payment_view_model.dart';
import 'package:frontend/views/orders/order_success_screen.dart';
import 'package:frontend/provider/cart_provider.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String orderId;
  final double totalAmount;

  const PaymentMethodScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selectedMethod = 'COD';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Phương thức thanh toán'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin đơn hàng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, color: theme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đơn hàng #${widget.orderId.substring(widget.orderId.length - 8)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tổng tiền: \$${widget.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tiêu đề
            Text(
              'Chọn phương thức thanh toán',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),

            const SizedBox(height: 16),

            // Phương thức COD
            _buildPaymentMethodTile(
              icon: Icons.money,
              title: 'Thanh toán khi nhận hàng (COD)',
              subtitle: 'Thanh toán bằng tiền mặt khi nhận hàng',
              value: 'COD',
            ),

            // Phương thức MoMo
            _buildPaymentMethodTile(
              icon: Icons.account_balance_wallet,
              title: 'Thanh toán qua MoMo',
              subtitle: 'Quét mã QR để thanh toán qua ví MoMo',
              value: 'MOMO',
              iconColor: Colors.pink,
            ),

            const SizedBox(height: 40),

            // Nút thanh toán
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isProcessing
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Đang xử lý...'),
                          ],
                        )
                        : Text(
                          _selectedMethod == 'COD'
                              ? 'Hoàn tất đơn hàng'
                              : 'Thanh toán qua MoMo',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    Color? iconColor,
  }) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedMethod,
      onChanged: (String? newValue) {
        setState(() {
          _selectedMethod = newValue!;
        });
      },
      title: Row(
        children: [
          Icon(icon, color: iconColor ?? Colors.grey[700]),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 36.0),
        child: Text(subtitle),
      ),
      activeColor: Theme.of(context).primaryColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              _selectedMethod == value
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300]!,
          width: 1,
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      if (_selectedMethod == 'COD') {
        // Xử lý thanh toán COD
        // Chuyển tới màn hình thành công
        Provider.of<CartProvider>(context, listen: false).clear();

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
          (route) => false,
        );
      } else if (_selectedMethod == 'MOMO') {
        // Xử lý thanh toán MoMo
        final paymentViewModel = Provider.of<PaymentViewModel>(
          context,
          listen: false,
        );

        // Tạo thanh toán MoMo
        final success = await paymentViewModel.createMomoPayment(
          widget.orderId,
        );

        if (success) {
          // Mở URL thanh toán
          final opened = await paymentViewModel.openPaymentUrl();

          if (!opened) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Không thể mở ứng dụng MoMo. Vui lòng thử lại sau.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            // Sau khi mở URL, chờ người dùng hoàn tất thanh toán
            // Trong trường hợp thực tế, bạn sẽ cần một cơ chế để kiểm tra trạng thái thanh toán
            // Ở đây, chúng ta sẽ hiển thị một dialog để người dùng xác nhận
            if (!mounted) return;

            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (ctx) => AlertDialog(
                    title: const Text('Thanh toán MoMo'),
                    content: const Text(
                      'Bạn đã hoàn tất thanh toán qua MoMo chưa?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();

                          // Kiểm tra trạng thái thanh toán
                          final completed =
                              await paymentViewModel.checkPaymentStatus();

                          if (completed) {
                            // Thanh toán thành công
                            Provider.of<CartProvider>(
                              context,
                              listen: false,
                            ).clear();

                            if (!mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder:
                                    (context) => const OrderSuccessScreen(),
                              ),
                              (route) => false,
                            );
                          } else {
                            // Thanh toán thất bại hoặc chưa hoàn tất
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Thanh toán chưa hoàn tất. Vui lòng thử lại hoặc chọn phương thức thanh toán khác.',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        child: const Text('Đã thanh toán'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Chưa thanh toán'),
                      ),
                    ],
                  ),
            );
          }
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(paymentViewModel.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
