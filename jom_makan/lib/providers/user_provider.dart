import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:jom_makan/models/complain.dart';
import 'package:jom_makan/models/review.dart';
import 'package:jom_makan/repositories/auth_repository.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/user_repository.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final AuthRepository _authRepository = AuthRepository();
  //final AuthRepository _authRepository = AuthRepository();

  auth.User? _firebaseUser;
  User? _userData;
  bool? _isHistoryLoading;
  bool _isLoading = false;
  String _postCount = "0";
  String? _likeCount = "0";
  String? _bookingCount = "0";
  List<User>? _allUsers = [];
  List<User> _users = [];
  User? _user;
  final bool _isComplainsLoading = false;
  final List<Complain> _allComplains = [];
  final bool _isLoadingComplains = false;
  List<Map<String, dynamic>> _resolvedComplains = [];
  List<Map<String, dynamic>> _unresolvedComplains = [];
  List<Review> _reviews = [];
  String _reviewCount = "0";

  List<User> get users => _users;
  List<Map<String, dynamic>> get resolvedComplains => _resolvedComplains;
  List<Map<String, dynamic>> get unresolvedComplains => _unresolvedComplains;
  List<Complain> get allComplains => _allComplains;
  bool get isLoadingComplains => _isLoadingComplains;
  bool get isComplainsLoading => _isComplainsLoading;
  auth.User? get firebaseUser => _firebaseUser;
  User? get userData => _userData;
  bool? get isHistoryLoading => _isHistoryLoading;
  bool get isLoading => _isLoading;
  String? get postCount => _postCount;
  String? get likeCount => _likeCount;
  String? get bookingCount => _bookingCount;
  List<Review> get reviews => _reviews;
  String? get reviewCount => _reviewCount;

  UserProvider(auth.User? firebaseUser) {
    _firebaseUser = firebaseUser;
    print("CURRENT: $_firebaseUser");
    if (_firebaseUser != null) {
      fetchUserDatabyUid(_firebaseUser!.uid);
    }
  }



  Future<void> initialize(auth.User? firebaseUser) async {
    _firebaseUser = firebaseUser;
    if (_firebaseUser != null) {
      await fetchUserDatabyUid(_firebaseUser!.uid);
    }
    notifyListeners();
  }

Future<Map<String, dynamic>> findTopUsers() async {
  String? topUserByPosts;
  String? topUserByLikes;
  int maxPosts = 0;
  int maxLikes = 0;

  // Iterate through all users to find the top users by post and like counts
  for (var user in _allUsers!) {
    // Parse the postCount and likeCount from strings to integers
    final postCount = int.tryParse(await _userRepository.fetchPostCount(user.userID)) ?? 0; // Default to 0 if parsing fails
    final likeCount = int.tryParse(await _userRepository.fetchLikeCount(user.userID)) ?? 0; // Default to 0 if parsing fails
    print('User: ${user.fullName}, Post Count: $postCount, Like Count: $likeCount');

    // Find the top user by post count
    if (postCount > maxPosts) {
      maxPosts = postCount;
      topUserByPosts = user.fullName;
    }

    // Find the top user by like count
    if (likeCount > maxLikes) {
      maxLikes = likeCount;
      topUserByLikes = user.fullName;
    }
  }
  return {
    'topUserByPosts': topUserByPosts,
    'topUserByLikes': topUserByLikes,
    'maxPosts': maxPosts,
    'maxLikes': maxLikes,
  };
}

  Future<void> fetchAllUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allUsers = await _userRepository.fetchAllUsers();
      _users = _allUsers ?? [];
      print('Number of Users loaded: ${_allUsers!.length}'); // Debugging line
    } catch (e) {
      _users = [];
      print(
          'Error in UserProvider: $e'); // This will show the error in provider
    }
    _isLoading = false;
    notifyListeners();
  }

  int get totalUserCount {
    return _allUsers?.length ?? 0;
  }

  Future<void> fetchUserData() async {
    _isLoading = true;
    notifyListeners();

    await fetchUserDatabyUid(_authRepository.currentUser!.uid);
    await _fetchUserStats();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserData(
      Map<String, dynamic> data, XFile? imageFile) async {
    if (_firebaseUser != null) {
      await _userRepository.updateUserData(_firebaseUser!.uid, data, imageFile);
      // Fetch the updated user data to reflect changes
      await fetchUserDatabyUid(_firebaseUser!.uid);
    } else {
      print('No user is signed in.');
    }
  }

  void searchUsers(String searchText) {
    if (searchText.isEmpty) {
      _users = _allUsers!;
    } else {
      _users = _allUsers!.where((user) {
        return user.fullName.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<void> fetchUserDatabyUid(String uid) async {
    _userData = await _userRepository.getUserData(uid);
    notifyListeners(); // Notify listeners after fetching user data
  }

  ///   uid (String): The unique identifier of the user whose data is to be fetched.

  void clearUserData() {
    _userData = null;
    notifyListeners();
  }

  Future<void> _fetchUserStats() async {
    try {
      _postCount = await _userRepository
          .fetchPostCount(_authRepository.currentUser!.uid);
      _likeCount = await _userRepository
          .fetchLikeCount(_authRepository.currentUser!.uid);
      _bookingCount = await _userRepository
          .fecthBookingCount(_authRepository.currentUser!.uid);
      _reviewCount = await _userRepository
          .fetchReviewCount(_authRepository.currentUser!.uid);
    } catch (e) {
      print('Error in EventProvider: $e');
    }
  }

  Future<void> fetchAllReviews(String userId) async {
    notifyListeners();
    try {
      _reviews = await _userRepository.fetchAllReviews();
    } catch (e) {
      _reviews = [];
      print('Error in UserProvider: $e');
    }
    notifyListeners();
  }

  Future<void> fetchUserInfo(String userId) async {
    try {
      _postCount = await _userRepository.fetchPostCount(userId);
      _reviewCount = await _userRepository.fetchReviewCount(userId);
    } catch (e) {
      _reviews = [];
      _postCount = '0';
      print('Error in EventProvider: $e');
    }
  }

  // Load and classify complains
  // Method to load and classify complains
  Future<void> loadClassifiedComplains() async {
    final classifiedComplains =
        await _userRepository.fetchClassifiedcomplains();
    _resolvedComplains = classifiedComplains['resolved']!;
    _unresolvedComplains = classifiedComplains['unresolved']!;
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userRepository.editUser(user);

      // Fetch updated store details to ensure local data is up-to-date
      await fetchAllUsers();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error in StoreProvider: $e');
      throw Exception('Error updating store');
    }
  }
}
