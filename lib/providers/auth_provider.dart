import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _currentUserEmail;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserEmail => _currentUserEmail;

  AuthProvider() {
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token != null) {
      _isAuthenticated = true;
      _currentUserEmail = prefs.getString('userEmail');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 1500));

    final prefs = await SharedPreferences.getInstance();
    final storedPassword = prefs.getString('user_$email');

    _setLoading(false);

    if (storedPassword == password) {
      await prefs.setString('authToken', 'valid_token_$email');
      await prefs.setString('userEmail', email);
      _isAuthenticated = true;
      _currentUserEmail = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signUp(String email, String password, String username) async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 1500));

    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('user_$email')) {
      _setLoading(false);
      return false;
    }

    await prefs.setString('user_$email', password);
    await prefs.setString('username_$email', username);

    await prefs.setString('authToken', 'valid_token_$email');
    await prefs.setString('userEmail', email);
    _isAuthenticated = true;
    _currentUserEmail = email;

    _setLoading(false);
    notifyListeners();
    return true;
  }
}
