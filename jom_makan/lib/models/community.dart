import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  final String postId;
  final String userId;
  final String userRole;
  final String title;
  final String content;
  final int likes;
  final List<String> tags;
  final Timestamp timestamp;

  CommunityPost({
    required this.postId,
    required this.userId,
    required this.userRole,
    required this.title,
    required this.content,
    required this.likes,
    required this.tags,
    required this.timestamp,
  });

  factory CommunityPost.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return CommunityPost(
      postId: doc.id,
      userId: data['userID'],
      userRole: data['userRole'],
      content: data['content'] ?? '',
      title: data['title'] ?? '',
      likes: data['likes'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userRole': userRole,
      'content': content,
      'title': title,
      'likes': likes,
      'tags': tags,
      'timestamp': timestamp,
    };
  }
}
