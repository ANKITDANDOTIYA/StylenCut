import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  bool _isDarkMode;

  bool get isDarkMode => _isDarkMode;

  ThemeViewModel([bool initialDarkMode = false]) : _isDarkMode = initialDarkMode;

  Future<void> toggleTheme(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }
}

