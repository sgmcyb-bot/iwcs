import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import 'database_service.dart';
import 'firestore_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();
  final DatabaseService _db = DatabaseService();
  
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  /// Monitor internal authentication changes
  Stream<User?> get userStream => _auth.authStateChanges();

  /// Attempt to restore the user profile from Firestore/Local Hive
  Future<UserModel?> initialize() async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      // Prioritize Cloud Profile
      _currentUser = await _firestore.getUser(user.email!);
      
      // Fallback/Cache to Local Database
      _currentUser ??= _db.getUser(user.email!);
      
      return _currentUser;
    }
    return null;
  }

  /// Login with email and password (Firebase)
  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password
      );
      
      if (credential.user != null) {
        _currentUser = await _firestore.getUser(credential.user!.email!);
        if (_currentUser != null) {
          await _db.saveUser(_currentUser!); // Sync cache
        }
        return _currentUser;
      }
    } catch (e) {
      // Local check for prototype testing if no internet/not configured
      final user = _db.getUser(email.trim().toLowerCase());
      if (user != null && user.password == password) {
        _currentUser = user;
        return user;
      }
    }
    return null;
  }

  /// Register a new public user (Firebase + Firestore)
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String city,
    String phone = '',
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      if (credential.user != null) {
        final user = UserModel(
          id: credential.user!.uid,
          name: name.trim(),
          email: normalizedEmail,
          password: '', // Managed by Firebase
          role: 'public',
          city: city,
          phone: phone,
        );

        await _firestore.saveUser(user);
        await _db.saveUser(user); // Cache
        _currentUser = user;
        return null; // Success
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
    return 'Unknown error during registration';
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? city,
  }) async {
    if (_currentUser == null) return;

    if (name != null) _currentUser!.name = name;
    if (phone != null) _currentUser!.phone = phone;
    if (city != null) _currentUser!.city = city;

    await _firestore.saveUser(_currentUser!);
    await _db.saveUser(_currentUser!);
  }
}
