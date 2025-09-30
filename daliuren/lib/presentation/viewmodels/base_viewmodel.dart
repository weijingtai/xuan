import 'package:flutter/foundation.dart';

enum ViewState { idle, loading, success, error }

class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String _message = '';

  ViewState get state => _state;
  String get message => _message;

  bool get isLoading => _state == ViewState.loading;
  bool get isSuccess => _state == ViewState.success;
  bool get isError => _state == ViewState.error;
  bool get isIdle => _state == ViewState.idle;

  void setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  void setStateWithMessage(ViewState viewState, String message) {
    _state = viewState;
    _message = message;
    notifyListeners();
  }

  void setLoading() => setState(ViewState.loading);
  void setSuccess() => setState(ViewState.success);
  void setError(String message) => setStateWithMessage(ViewState.error, message);
  void setIdle() => setState(ViewState.idle);
}