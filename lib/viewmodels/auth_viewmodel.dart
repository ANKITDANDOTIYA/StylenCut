import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = '';
    
    try {
      final result = await AuthService.login(email, password);
      
      if (result['success'] == true) {
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Login failed';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signup(String name, String email, String password, String role, {
    String? salonName,
    String? address,
    String? phoneNumber,
    String? openingTime,
    String? closingTime,
  }) async {
    _setLoading(true);
    _errorMessage = '';
    
    try {
      final result = await AuthService.signup(
        name, email, password, role, 
        salonName: salonName,
        address: address,
        phoneNumber: phoneNumber,
        openingTime: openingTime,
        closingTime: closingTime,
      );
      
      if (result['success'] == true) {
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Signup failed';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    notifyListeners();
  }
}
