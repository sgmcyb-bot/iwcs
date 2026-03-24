import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _db = DatabaseService();

  UserModel? get currentUser => _authService.currentUser;
  bool get isLoggedIn => _authService.isLoggedIn;
  String get userRole => currentUser?.role ?? '';
  String get userCity => currentUser?.city ?? '';

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500)); // Simulated delay

    final user = _authService.login(email, password);
    _isLoading = false;

    if (user != null) {
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Invalid email or password';
      notifyListeners();
      return false;
    }
  }

  /// Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String city,
    String phone = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final error = await _authService.register(
      name: name,
      email: email,
      password: password,
      city: city,
      phone: phone,
    );

    _isLoading = false;

    if (error == null) {
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = error;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  void logout() {
    _authService.logout();
    notifyListeners();
  }

  /// Get all users (admin only)
  List<UserModel> getAllUsers() => _db.getAllUsers();

  /// Get volunteers by city
  List<UserModel> getVolunteersByCity(String city) =>
      _db.getVolunteersByCity(city);

  /// Update user role (admin only)
  Future<void> updateUserRole(UserModel user, String newRole) async {
    user.role = newRole;
    await _db.saveUser(user);
    notifyListeners();
  }

  /// Toggle user active status (admin only)
  Future<void> toggleUserActive(UserModel user) async {
    user.isActive = !user.isActive;
    await _db.saveUser(user);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
