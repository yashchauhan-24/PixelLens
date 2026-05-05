import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._authService) {
    _restoreSession();
  }

  final AuthService _authService;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  Future<void> _restoreSession() async {
    try {
      _currentUser = await _authService.fetchCurrentUser();
      notifyListeners();
    } catch (_) {
      // Keep app usable even if session restore fails.
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(email.trim(), password.trim());
      _isLoading = false;
      if (user == null) {
        _errorMessage = 'Invalid email or password.';
        notifyListeners();
        return false;
      }
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      _isLoading = false;
      if (user == null) {
        _errorMessage = 'Google sign in cancelled.';
        notifyListeners();
        return false;
      }
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<AppUser?> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Update current user's profile information.
  /// Returns the updated user or null on failure.
  Future<AppUser?> updateProfile({required String name, String? phone, String? address}) async {
    if (_currentUser == null) return null;
    _isLoading = true;
    notifyListeners();

    try {
      final updated = _currentUser!.copyWith(name: name, phone: phone, address: address);
      final result = await _authService.updateUserProfile(updated);

      _isLoading = false;
      if (result != null) {
        _currentUser = result;
        notifyListeners();
        return result;
      }

      _errorMessage = 'Unable to update profile.';
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// Validates old password and updates password using FirebaseAuth.
  Future<bool> changePassword({required String oldPassword, required String newPassword}) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final ok = await _authService.changePassword(oldPassword, newPassword);
      _isLoading = false;
      if (!ok) {
        _errorMessage = 'Unable to change password.';
        notifyListeners();
      }
      return ok;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
