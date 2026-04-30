import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authService.isAuthenticated;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state
  void _initializeAuth() {
    print('[AUTH] _initializeAuth called');
    _authService.authStateChanges.listen((user) {
      print('[AUTH] authStateChanges fired: user=$user');
      if (user != null) {
        print('[AUTH] User authenticated: ${user.uid}');
        _loadUserData(user.uid);
      } else {
        print('[AUTH] User signed out');
        _user = null;
        notifyListeners();
      }
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      print('[AUTH] Loading user data for uid=$uid');
      final userData = await _authService.getUserData(uid);
      print('[AUTH] User data loaded: displayName=${userData?.displayName}');
      _user = userData;
      _error = null;
      notifyListeners();
    } catch (e) {
      print('[AUTH] Error loading user data: $e');
      _error = 'Failed to load user data: $e';
      notifyListeners();
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final (user, error) = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = error;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Sign up failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final (user, error) = await _authService.signIn(
        email: email,
        password: password,
      );

      if (user != null) {
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = error;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Sign in failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _user = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Sign out failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update display name
  Future<bool> updateDisplayName(String displayName) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.updateDisplayName(displayName);
      if (_user != null) {
        _user = _user!.copyWith(displayName: displayName);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Update failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
