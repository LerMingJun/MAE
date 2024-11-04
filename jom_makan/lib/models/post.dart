import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jom_makan/models/activity.dart';
import 'package:jom_makan/models/user.dart';


class Post {
  final String postID;
  final String postImage;
  final String title;
  final String description;
  final String activityID;
  final String activityName;
  final List<String> likes;
  final Timestamp createdAt;
  User? user;

  Post({
    required this.postID, 
    required this.postImage,
    required this.title,
    required this.description,
    required this.activityID,
    required this.activityName,
    required this.likes,
    required this.createdAt,
    this.user,
  });

  // Factory method to create an instance from Firestore data
  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Post(
      postID: doc.id,
      postImage: data['postImage'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      activityID: data['activityID'] ?? '',
      activityName: data['activityName'] ?? '',
      likes: List<String>.from(data['likes'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Method to convert an instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'postID': postID,
      'postImage': postImage,
      'title': title,
      'description': description,
      'activityID': activityID,
      'activityName': activityName,
      'likes': likes,
      'createdAt': createdAt,
    };
  }
}
