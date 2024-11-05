import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/constants/placeholderURL.dart';

class User {
  final String userID;
  final String fullName;
  final String username;
  final String email;
  final String profileImage;
  final List<String> dietaryPreferences;
  final Timestamp createdAt;
  final bool isDelete;
  final bool isSuspend;
  final String commentByAdmin;

  User({
    required this.userID,
    required this.fullName,
    required this.username,
    required this.email,
    this.profileImage = "",
    List<String>? dietaryPreferences, // Make optional
    required this.createdAt,
    required this.isDelete,
    required this.isSuspend,
    required this.commentByAdmin
    
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
      isDelete: data['isDelete'],
      isSuspend: data['isSuspend'],
      commentByAdmin: data['commentByAdmin'],
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
      'isDelete': isDelete,
      'isSuspend': isSuspend,
      'commentByAdmin': commentByAdmin  
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



  User copyWith({
    String? userID,
    String? fullName,
    String? username,
    String? email,
    String? profileImage,
    List<String>? dietaryPreferences,
    Timestamp? createdAt,
    bool? isDelete,
    bool? isSuspend,
    String? commentByAdmin,
  }) {
    return User(
      userID: userID ?? this.userID,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      createdAt: createdAt ?? this.createdAt,
      isDelete: isDelete ?? this.isDelete,
      isSuspend: isSuspend ?? this.isSuspend,
      commentByAdmin: commentByAdmin ?? this.commentByAdmin,
    );
  }

}
