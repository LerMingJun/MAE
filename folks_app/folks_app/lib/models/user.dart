import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:folks_app/constants/placeholderURL.dart';

class User {
  final String userID;
  final String fullName;
  final String username;
  final String email;
  final String profileImage;
  final List<String> dietaryPreferences;
  final Timestamp createdAt;

  User({
    required this.userID,
    required this.fullName,
    required this.username,
    required this.email,
    this.profileImage = "",
    List<String>? dietaryPreferences, // Make optional
    required this.createdAt,
  }) : dietaryPreferences = dietaryPreferences ?? []; // Initialize to empty list if null

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      userID: data['userID'],
      fullName: data['fullName'],
      username: data['username'],
      email: data['email'],
      profileImage: data['profileImage'] != "userPlaceholder" ? data['profileImage'] : userPlaceholder,
      dietaryPreferences: List<String>.from(data['dietaryPreferences'] ?? []), // Safely handle null
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'fullName': fullName,
      'username': username,
      'email': email,
      'profileImage': profileImage,
      'dietaryPreferences': dietaryPreferences,
      'createdAt': createdAt,
    };
  }
  
  // Example method to add a dietary preference
  void addDietaryPreference(String preference) {
    if (!dietaryPreferences.contains(preference)) {
      dietaryPreferences.add(preference);
    }
  }
  
  @override
  String toString() {
    return 'User(userID: $userID, fullName: $fullName, username: $username, email: $email)';
  }
}
