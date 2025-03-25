// lib/view_models/order_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:frontend/models/order.dart';
import 'package:frontend/services/order_service.dart';
import 'package:frontend/utils/shared_prefs.dart';

enum OrderLoadingStatus { initial, loading, loaded, error }

class OrderViewModel with ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  OrderLoadingStatus _status = OrderLoadingStatus.initial;
  String _errorMessage = '';

  List<Order> get orders => _orders;
  OrderLoadingStatus get status => _status;
  String get errorMessage => _errorMessage;
  int get orderCount => _orders.length;

  Future<void> fetchUserOrders() async {
    // Only update status if not already loading
    if (_status != OrderLoadingStatus.loading) {
      _status = OrderLoadingStatus.loading;
      notifyListeners();
    }

    try {
      final token = await SharedPrefs.getToken();
      final userId = await SharedPrefs.getUserId();

      if (token == null || userId == null) {
        _status = OrderLoadingStatus.error;
        _errorMessage = 'Authentication required';
        notifyListeners();
        return;
      }

      final result = await _orderService.getUserOrders(userId, token);

      if (result['success']) {
        _orders = result['data'];
        _status = OrderLoadingStatus.loaded;
      } else {
        _status = OrderLoadingStatus.error;
        _errorMessage = result['message'];
      }
    } catch (e) {
      _status = OrderLoadingStatus.error;
      _errorMessage = e.toString();
      debugPrint('Error in OrderViewModel: $e');
    }

    notifyListeners();
  }
}
