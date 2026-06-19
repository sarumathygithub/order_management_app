import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  User? get currentUser => _authService.currentUser;

  String get userEmail => currentUser?.email ?? 'Unknown';

  String get userName {
    final email = currentUser?.email;
    if (email == null || email.isEmpty) return 'User';

    final localPart = email.split('@').first;
    if (localPart.isEmpty) return 'User';

    return localPart[0].toUpperCase() + localPart.substring(1);
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.login(email, password);

      return true;
    } catch (e) {
      debugPrint('Login Error : $e');

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
