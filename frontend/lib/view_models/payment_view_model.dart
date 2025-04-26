// lib/view_models/payment_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:frontend/config/api_config.dart';
import '../services/payment_service.dart';
import 'base_view_model.dart';

class PaymentViewModel extends BaseViewModel {
  final PaymentService _paymentService = PaymentService();
  String? _paymentUrl;
  String? _paymentId;
  String? _orderId;

  String? get paymentUrl => _paymentUrl;
  String? get paymentId => _paymentId;
  String? get orderId => _orderId;

  // Tạo thanh toán MoMo
  Future<bool> createMomoPayment(String orderId) async {
    setBusy();
    try {
      // Lấy URL của trang kết quả thanh toán
      final returnUrl = 'http://${ApiConfig.serverIP}:3000/payment/callback';

      final result = await _paymentService.createMomoPayment(
        orderId,
        returnUrl,
      );

      if (result['success'] == true) {
        _paymentUrl = result['paymentUrl'];
        _paymentId = result['paymentId'];
        _orderId = orderId;
        setIdle();
        return true;
      } else {
        setError(result['message'] ?? 'Không thể tạo thanh toán MoMo');
        return false;
      }
    } catch (e) {
      setError('Lỗi khi tạo thanh toán: ${e.toString()}');
      return false;
    }
  }

  // Mở URL thanh toán
  Future<bool> openPaymentUrl() async {
    if (_paymentUrl == null) {
      setError('Không có URL thanh toán');
      return false;
    }

    try {
      final result = await _paymentService.openMomoPaymentUrl(_paymentUrl!);
      return result;
    } catch (e) {
      setError('Không thể mở URL thanh toán: ${e.toString()}');
      return false;
    }
  }

  // Kiểm tra trạng thái thanh toán
  Future<bool> checkPaymentStatus() async {
    if (_paymentId == null) {
      setError('Không có ID thanh toán để kiểm tra');
      return false;
    }

    setBusy();
    try {
      final result = await _paymentService.checkPaymentStatus(_paymentId!);

      if (result['success'] == true) {
        final payment = result['payment'];
        final isCompleted = payment['status'] == 'COMPLETED';
        setIdle();
        return isCompleted;
      } else {
        setError(result['message'] ?? 'Không thể kiểm tra thanh toán');
        return false;
      }
    } catch (e) {
      setError('Lỗi khi kiểm tra thanh toán: ${e.toString()}');
      return false;
    }
  }

  // Xử lý thanh toán (dùng cho trường hợp không dùng webhook)
  Future<bool> processPayment(String orderId, String resultCode) async {
    setBusy();
    try {
      final result = await _paymentService.processPayment(orderId, resultCode);

      if (result['success'] == true) {
        setIdle();
        return true;
      } else {
        setError(result['message'] ?? 'Không thể xử lý thanh toán');
        return false;
      }
    } catch (e) {
      setError('Lỗi khi xử lý thanh toán: ${e.toString()}');
      return false;
    }
  }

  // Reset state
  void reset() {
    _paymentUrl = null;
    _paymentId = null;
    _orderId = null;
    setIdle();
  }
}
