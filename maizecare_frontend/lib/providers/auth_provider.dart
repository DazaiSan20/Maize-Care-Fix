import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/api_response.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Listen to auth state changes
    _authRepository.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Register
  Future<ApiResponse> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      if (response.success) {
        _user = _authRepository.currentUser;
        _userData = response.data;
      } else {
        _errorMessage = response.message;
      }

      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      if (response.success) {
        _user = _authRepository.currentUser;
        _userData = response.data;
      } else {
        _errorMessage = response.message;
      }

      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with Google
  Future<ApiResponse> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.loginWithGoogle();

      if (response.success) {
        _user = _authRepository.currentUser;
        _userData = response.data;
      } else {
        _errorMessage = response.message;
      }

      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Forgot Password
  Future<ApiResponse> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.forgotPassword(email);
      
      if (!response.success) {
        _errorMessage = response.message;
      }

      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.logout();
      _user = null;
      _userData = null;
      _errorMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if logged in
  Future<bool> checkLoginStatus() async {
    return await _authRepository.isLoggedIn();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}