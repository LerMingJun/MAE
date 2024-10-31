import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:folks_app/models/user.dart';
import 'package:folks_app/repositories/auth_repository.dart';
import 'package:folks_app/repositories/user_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  auth.User? _firebaseUser;
  bool _isLoading = false;
  User? _userData;

  auth.User? get user => _firebaseUser;
  bool get isLoading => _isLoading;
  User? get userData => _userData;

  // Sign in with email and password and notify listeners
  Future<void> signInWithEmail(String email, String password) async {
    _setLoadingState(true);
    _firebaseUser = await _authRepository.signInWithEmail(email, password);
    if (_firebaseUser != null) {
      await fetchUserData(_firebaseUser!.uid);
    }
    _setLoadingState(false);
  }

  // Sign in with Google and notify listeners
  Future<void> signInWithGoogle() async {
    _setLoadingState(true);
    _firebaseUser = await _authRepository.signInWithGoogle();
    if (_firebaseUser != null) {
      await fetchUserData(_firebaseUser!.uid);
    }
    _setLoadingState(false);
  }

  Future<void> signUpWithEmail(String email, String password, String fullname, String username) async {
    _setLoadingState(true);
    _firebaseUser = await _authRepository.signUpWithEmail(email, password, fullname, username);
    if (_firebaseUser != null) {
      await fetchUserData(_firebaseUser!.uid);
    }
    _setLoadingState(false);
  }

  // Sign out and notify listeners
  Future<void> signOut() async {
    await _authRepository.logout();
    _firebaseUser = null;
    _userData = null;
    notifyListeners();
  }

  // Check current user and notify listeners
  void checkCurrentUser() {
    _firebaseUser = _authRepository.currentUser;
    if (_firebaseUser != null) {
      fetchUserData(_firebaseUser!.uid);
    }
    notifyListeners();
  }

  Future<void> fetchUserData(String uid) async {
    _userData = await _userRepository.getUserData(uid);
    notifyListeners();
  }

   void _setLoadingState(bool isLoading) {
    _isLoading = isLoading;
    print("Setting loading state to: $isLoading");
    notifyListeners();
  }
}
