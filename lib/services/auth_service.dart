import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _db = DatabaseService();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Login with email and password
  /// Returns the user if successful, null if failed
  UserModel? login(String email, String password) {
    final user = _db.getUser(email.trim().toLowerCase());
    if (user != null && user.password == password && user.isActive) {
      _currentUser = user;
      return user;
    }
    return null;
  }

  /// Register a new public user
  /// Returns error message string, or null if successful
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String city,
    String phone = '',
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    // Check if user already exists
    if (_db.getUser(normalizedEmail) != null) {
      return 'An account with this email already exists';
    }

    // Validate
    if (name.trim().isEmpty) return 'Name is required';
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return 'Valid email is required';
    }
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (city.isEmpty) return 'City is required';

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: normalizedEmail,
      password: password,
      role: 'public', // Public users register themselves
      city: city,
      phone: phone,
    );

    await _db.saveUser(user);
    _currentUser = user;
    return null; // Success
  }

  void logout() {
    _currentUser = null;
  }

  /// Update user profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? city,
  }) async {
    if (_currentUser == null) return;

    if (name != null) _currentUser!.name = name;
    if (phone != null) _currentUser!.phone = phone;
    if (city != null) _currentUser!.city = city;

    await _db.saveUser(_currentUser!);
  }

  /// Change password
  Future<String?> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return 'Not logged in';
    if (_currentUser!.password != oldPassword) return 'Current password is incorrect';
    if (newPassword.length < 6) return 'New password must be at least 6 characters';

    _currentUser!.password = newPassword;
    await _db.saveUser(_currentUser!);
    return null;
  }
}
