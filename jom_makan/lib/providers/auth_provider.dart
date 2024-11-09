import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:jom_makan/models/user.dart';
import 'package:jom_makan/repositories/auth_repository.dart';
import 'package:jom_makan/repositories/user_repository.dart';
import 'package:jom_makan/repositories/restaurant_repository.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart'; // Import firebase_storage

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();
  final RestaurantRepository _restaurantRepository = RestaurantRepository();

  auth.User? _firebaseUser;
  bool _isLoading = false;
  User? _userData;
  Restaurant? _restaurantData;

  auth.User? get user => _firebaseUser;
  bool get isLoading => _isLoading;
  User? get userData => _userData;
  Restaurant? get restaurantData => _restaurantData;

  // Sign in with email and password and notify listeners
  Future<void> signInWithEmail(String email, String password) async {
    _setLoadingState(true);
    _firebaseUser = await _authRepository.signInWithEmail(email, password);
    if (_firebaseUser != null) {
      await fetchUserData(_firebaseUser!.uid);
    }
    _setLoadingState(false);
  }

  // Sign in with email and password for restaurant
  Future<void> signInRestaurantWithEmail(String email, String password) async {
    _setLoadingState(true);
    _firebaseUser = await _authRepository.signInWithEmail(email, password);
    if (_firebaseUser != null) {
      await fetchRestaurantData(_firebaseUser!.uid);
    }
    _setLoadingState(false);
  }

  Future<void> signUpWithEmail(String email, String password, String fullname,
      String username, List<String> dietaryPreferences) async {
    _setLoadingState(true);
    _firebaseUser = await _authRepository.signUpWithEmail(
        email, password, fullname, username, dietaryPreferences);
    if (_firebaseUser != null) {
      await fetchUserData(_firebaseUser!.uid);
    }
    _setLoadingState(false);
  }

  Future<void> signUpRestaurantWithEmail({
    required String email,
    required String password,
    required String name,
    required GeoPoint location,
    required List<String> cuisineType,
    required List<String> menu,
    required Map<String, OperatingHours> operatingHours,
    required String intro,
    required List<File> menuImages,
    required List<String> tags,
    File? profileImage,
  }) async {
    _setLoadingState(true);

    try {
      if (profileImage == null) {
        throw Exception('Profile image is required.');
      }

      // Step 1: Complete sign-up to obtain UID
      _firebaseUser = await _authRepository.signUpRestaurantWithEmail(
        email: email,
        password: password,
        name: name,
        location: location,
        cuisineType: cuisineType,
        menu: [], // Temporarily set as empty, update after image uploads
        operatingHours: operatingHours,
        intro: intro,
        image:
            '', // Temporarily set as empty, update after profile image upload
        tags: tags,
      );

      if (_firebaseUser == null) {
        throw Exception('Signup failed, Firebase user is null.');
      }

      // Step 2: Use the restaurant's UID for image uploads
      String restaurantId = _firebaseUser!.uid;

      // Upload menu images and profile image using the restaurant UID
      List<String> menuImageUrls =
          await _uploadImages(menuImages, restaurantId);
      String profileImageUrl =
          (await _uploadImages([profileImage], restaurantId)).first;

      // Step 3: Update Firestore with the image URLs
      await _restaurantRepository.updateRestaurantImages(
        restaurantId: restaurantId,
        menuImageUrls: menuImageUrls,
        profileImageUrl: profileImageUrl,
      );

      // Fetch restaurant data for local use if needed
      _restaurantData =
          await _restaurantRepository.getRestaurantData(restaurantId);
    } catch (e) {
      print("Error during restaurant sign-up: $e");
    } finally {
      _setLoadingState(false);
      notifyListeners();
    }
  }

  Future<List<String>> _uploadImages(
      List<File> images, String restaurantID) async {
    List<String> imageUrls = [];
    for (var image in images) {
      try {
        // Generate a unique path for each image
        final ref = FirebaseStorage.instance
            .ref()
            .child('restaurant_images/$restaurantID')
            .child(
                '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}');

        // Upload the file
        await ref.putFile(image);

        // Get the download URL
        String url = await ref.getDownloadURL();
        imageUrls.add(url);
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
    return imageUrls;
  }

  // Sign out and notify listeners
  Future<void> signOut() async {
    await _authRepository.logout();
    _firebaseUser = null;
    _userData = null;
    _restaurantData = null;
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

  Future<void> fetchRestaurantData(String uid) async {
    _restaurantData = await _restaurantRepository.getRestaurantData(uid);
    notifyListeners();
  }

  void _setLoadingState(bool isLoading) {
    _isLoading = isLoading;
    print("Setting loading state to: $isLoading");
    notifyListeners();
  }
}
