import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/models/user.dart';

class Post {
  final String postId;
  final String userID;
  final String userRole;
  final String title;
  final String description;
  final List<String> likes;
  final List<String> tags;
  final String postImage;
  final Timestamp createdAt;
  User? user;

  Post({
    required this.postId,
    required this.userID,
    required this.userRole,
    required this.title,
    required this.description,
    required this.likes,
    required this.tags,
    required this.createdAt,
    required this.postImage,
    this.user,
  });

  // Method to create an instance from a JSON object
  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    print(data);
    return Post(
      postId: doc.id,
      userID: data['userID'] ?? '', // Default to empty string if null
      userRole: data['userRole'] ?? '',
      description: data['description'] ?? '',
      title: data['title'] ?? '',
      // likes: data['likes'] ?? 0,
      likes: List<String>.from(data['likes'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      postImage: data['postImage'] ?? '',
    );
  }

  // Method to convert an instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'userRole': userRole,
      'description': description,
      'title': title,
      'likes': likes,
      'tags': tags,
      'createdAt': createdAt,
      'postImage': postImage
    };
  }
}
