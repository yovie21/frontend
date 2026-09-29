import 'package:flutter/material.dart';
import '../../data/services/services.dart';
import '../../data/models/models.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<bool> checkAuth() async {
    _isLoading = true;
    try {
      _user = await AuthService.me();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _user = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await AuthService.login(username, password);
      await AuthService.setToken(res.token);
      _user = res.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.clearToken();
    _user = null;
    notifyListeners();
  }
}
