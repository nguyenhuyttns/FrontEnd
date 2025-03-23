// lib/view_models/base_view_model.dart
import 'package:flutter/foundation.dart';

enum ViewState { idle, busy, error }

class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String _errorMessage = '';

  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isBusy => _state == ViewState.busy;
  bool get isError => _state == ViewState.error;
  bool get isIdle => _state == ViewState.idle;

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _state = ViewState.error;
    notifyListeners();
  }

  void setIdle() {
    _state = ViewState.idle;
    notifyListeners();
  }

  void setBusy() {
    _state = ViewState.busy;
    notifyListeners();
  }
}
