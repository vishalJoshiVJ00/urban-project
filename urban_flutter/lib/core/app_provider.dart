import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  // 🌙 Dark Mode State
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // 👤 User Authentication State
  bool _isLoggedIn = false;
  String? _userRole; // 'admin' ya 'citizen'
  Map<String, dynamic>? _userData; // Signup details store karne ke liye

  bool get isLoggedIn => _isLoggedIn;
  String? get userRole => _userRole;
  Map<String, dynamic>? get userData => _userData;

  // 🌓 Theme Badalne ka Function
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Ye poori app ko batayega ki theme badal gayi hai
  }

  // 🔑 Login Success Function
  void loginUser(String role, Map<String, dynamic> data) {
    _isLoggedIn = true;
    _userRole = role;
    _userData = data; // Isme Name, Surname, DOB save hoga
    notifyListeners();
  }

  // 🚪 Logout Function
  void logout() {
    _isLoggedIn = false;
    _userRole = null;
    _userData = null;
    notifyListeners();
  }
}